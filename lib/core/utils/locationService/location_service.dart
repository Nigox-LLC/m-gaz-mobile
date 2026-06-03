import 'dart:math';
import 'dart:ui';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart' as ph;
import 'package:workmanager/workmanager.dart';

/// Toggle for QA: when `true`, tick fires every 30 seconds instead of
/// 30 minutes. MUST be `false` for any commit that ships to users.
///
/// NOTE: WorkManager periodic tasks have a hard 15-minute minimum on Android,
/// so this fast interval only affects manual/one-off testing, not the periodic
/// schedule.
const bool kDailyRouteDebugFastInterval = false;

/// Toggle for QA/debug: when `true`, working-hours gate (09:00-18:00) is
/// bypassed, so location ticks fire any time of day. MUST be `false` for any
/// commit that ships to users.
const bool kDailyRouteDebugBypassWorkingHours = false;

const Duration dailyRouteLocationInterval = kDailyRouteDebugFastInterval
    ? Duration(seconds: 30)
    : Duration(minutes: 30);

void _log(String msg) => debugPrint('[DailyRoute] $msg');

const String _baseUrl = 'https://backend.m-gaz.uz/api/';
const String _apiBoxName = 'api';
const String _queueBoxName = 'daily_route_location_queue';
const String _accessTokenKey = 'access_token';
const String _refreshTokenKey = 'refresh_token';
const String _employeeIdKey = 'employee_id';

/// WorkManager identifiers. The periodic task drives the recurring 30-minute
/// sync; the one-off task triggers an immediate first sync on start.
const String _workPeriodicUniqueName = 'daily_route_location_periodic';
const String _workOneOffUniqueName = 'daily_route_location_oneoff';
const String _workTaskName = 'dailyRouteLocationTick';

/// Top-level WorkManager entry point. Runs in a background isolate, so plugins
/// must be re-registered before use.
@pragma('vm:entry-point')
void dailyRouteCallbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) async {
    DartPluginRegistrant.ensureInitialized();
    await DailyRouteLocationService.runBackgroundSyncTick();
    // Always report success so the periodic chain keeps running; transient
    // failures are handled internally (queue + retry next tick).
    return true;
  });
}

class DailyRouteLocationService {
  DailyRouteLocationService._();

  static final DailyRouteLocationService _instance =
      DailyRouteLocationService._();

  factory DailyRouteLocationService() => _instance;

  /// Initializes the WorkManager dispatcher. Call once during app start
  /// (Android only). Safe to call multiple times.
  static Future<void> initializeWorkManager() async {
    if (defaultTargetPlatform != TargetPlatform.android) return;
    await Workmanager().initialize(dailyRouteCallbackDispatcher);
  }

  /// Registers the periodic background location sync via WorkManager. No
  /// foreground service / notification is used.
  Future<bool> ensureScheduled() async {
    if (defaultTargetPlatform != TargetPlatform.android) return false;

    await flushPending();

    final store = DailyRouteHiveLocalStore();
    await store.init();
    final credentials = await store.readCredentials();
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    final permission = await _requestLocationPermission();

    _log(
      'ensureScheduled: tokenSet=${credentials.accessToken.isNotEmpty}, '
      'employeeId=${credentials.employeeId}, serviceEnabled=$serviceEnabled, '
      'permission=$permission',
    );

    final canTrack = DailyRouteLocationPermissionPolicy.canTrack(
      credentials: credentials,
      serviceEnabled: serviceEnabled,
      permission: permission,
    );
    if (!canTrack) {
      _log('ensureScheduled: gate failed, work not scheduled');
      return false;
    }

    await Workmanager().registerPeriodicTask(
      _workPeriodicUniqueName,
      _workTaskName,
      frequency: dailyRouteLocationInterval,
      initialDelay: Duration.zero,
      existingWorkPolicy: ExistingPeriodicWorkPolicy.keep,
      constraints: Constraints(networkType: NetworkType.connected),
    );

    // Kick off an immediate first sync without waiting a full interval.
    await Workmanager().registerOneOffTask(
      _workOneOffUniqueName,
      _workTaskName,
      existingWorkPolicy: ExistingWorkPolicy.keep,
      constraints: Constraints(networkType: NetworkType.connected),
    );

    _log('ensureScheduled: periodic + one-off work registered');
    return true;
  }

  Future<void> stop() async {
    await Workmanager().cancelByUniqueName(_workPeriodicUniqueName);
    await Workmanager().cancelByUniqueName(_workOneOffUniqueName);
  }

  Future<int> flushPending() async {
    final store = DailyRouteHiveLocalStore();
    await store.init();
    final engine = DailyRouteSyncEngine(
      localStore: store,
      remoteClient: DailyRouteDioRemoteClient(),
    );
    return engine.flushPending();
  }

  static Future<bool> runBackgroundSyncTick() async {
    try {
      return await _runBackgroundSyncTick();
    } catch (e) {
      // Any failure in the killed-state isolate (path_provider, Hive, etc.)
      // must not bubble out of executeTask, otherwise WorkManager treats the
      // tick as failed and can back off / stop the periodic chain.
      _log('tick: unexpected error: $e');
      return true;
    }
  }

  static Future<bool> _runBackgroundSyncTick() async {
    final store = DailyRouteHiveLocalStore();
    await store.init();

    final engine = DailyRouteSyncEngine(
      localStore: store,
      remoteClient: DailyRouteDioRemoteClient(),
    );

    final flushed = await engine.flushPending();
    if (flushed > 0) _log('tick: flushed $flushed pending records');

    final credentials = await store.readCredentials();
    if (!credentials.canSend) {
      _log('tick: missing credentials, skipping');
      return false;
    }

    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    final permission = await Geolocator.checkPermission();
    final canTrack = DailyRouteLocationPermissionPolicy.canTrack(
      credentials: credentials,
      serviceEnabled: serviceEnabled,
      permission: permission,
    );
    if (!canTrack) {
      _log(
        'tick: gate failed (serviceEnabled=$serviceEnabled, '
        'permission=$permission)',
      );
      return false;
    }

    final now = DateTime.now();
    if (kDailyRouteDebugBypassWorkingHours) {
      _log('tick: working-hours gate BYPASSED (debug toggle)');
    } else if (!DailyRouteWorkingHoursPolicy.isWithinWorkingHours(now)) {
      _log(
        'tick: outside working hours (${now.hour}:${now.minute}), skipping GPS read',
      );
      return true;
    }

    try {
      _log('tick: requesting GPS position...');
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 30),
        ),
      );
      _log(
        'tick: GPS=${position.latitude},${position.longitude} '
        'speed=${position.speed} acc=${position.accuracy}',
      );
      await engine.enqueuePosition(position);
      final sent = await engine.flushPending();
      _log('tick: flushed after enqueue = $sent');
      return true;
    } catch (e) {
      _log('tick: getCurrentPosition error: $e');
      return true;
    }
  }

  /// Requests foreground then background (`always`) location permission and
  /// returns the resolved permission after escalation. Used by the UI gate so
  /// it can decide whether scheduling is allowed.
  Future<LocationPermission> requestAlwaysLocationPermission() {
    return _requestLocationPermission();
  }

  /// Requests exemption from OEM battery optimization (Doze) so WorkManager
  /// keeps firing after the app is swiped away. Android-only; returns true on
  /// other platforms where the concept does not apply.
  Future<bool> requestBatteryOptimizationBypass() async {
    if (defaultTargetPlatform != TargetPlatform.android) return true;
    final status = await ph.Permission.ignoreBatteryOptimizations.status;
    if (status.isGranted) return true;
    final result = await ph.Permission.ignoreBatteryOptimizations.request();
    _log('ignoreBatteryOptimizations.request() = $result');
    return result.isGranted;
  }

  /// Read-only check (no prompts) that BOTH `always` location and the battery
  /// optimization exemption are granted. Returns true off-Android.
  Future<bool> hasAlwaysLocationAndBatteryBypass() async {
    if (defaultTargetPlatform != TargetPlatform.android) return true;
    final permission = await Geolocator.checkPermission();
    if (permission != LocationPermission.always) return false;
    final battery = await ph.Permission.ignoreBatteryOptimizations.status;
    return battery.isGranted;
  }

  static Future<LocationPermission> _requestLocationPermission() async {
    var permission = await Geolocator.checkPermission();
    _log('checkPermission initial = $permission');
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      _log('after requestPermission(foreground) = $permission');
    }
    if (permission == LocationPermission.whileInUse) {
      try {
        final bgStatus = await ph.Permission.locationAlways.request();
        _log('locationAlways.request() = $bgStatus');
        final after = await Geolocator.checkPermission();
        _log('checkPermission after locationAlways = $after');
        return after;
      } catch (e) {
        _log('locationAlways request error: $e');
      }
    }
    return permission;
  }
}

class DailyRouteLocationPermissionPolicy {
  const DailyRouteLocationPermissionPolicy._();

  /// Tracking is allowed only when credentials are present, location services
  /// are enabled, and location permission is strictly `always`.
  ///
  /// `whileInUse` is intentionally rejected: once the app is killed/swiped from
  /// recents, Android's privacy gate blocks GPS access unless permission is
  /// `always`, so `getCurrentPosition` would fail silently in the background
  /// isolate. Requiring `always` up front avoids scheduling work that can never
  /// produce a fix after kill. No notification permission is required
  /// (WorkManager has no notification).
  static bool canTrack({
    required DailyRouteCredentials credentials,
    required bool serviceEnabled,
    required LocationPermission permission,
  }) {
    return credentials.canSend &&
        serviceEnabled &&
        permission == LocationPermission.always;
  }
}

class DailyRouteWorkingHoursPolicy {
  const DailyRouteWorkingHoursPolicy._();

  static const int startHour = 9;
  static const int endHourExclusive = 18;

  static bool isWithinWorkingHours(DateTime now) {
    final h = now.hour;
    return h >= startHour && h < endHourExclusive;
  }
}

class DailyRouteSyncEngine {
  DailyRouteSyncEngine({
    required DailyRouteLocalStore localStore,
    required DailyRouteRemoteClient remoteClient,
  }) : _localStore = localStore,
       _remoteClient = remoteClient;

  final DailyRouteLocalStore _localStore;
  final DailyRouteRemoteClient _remoteClient;
  bool _isFlushing = false;

  Future<bool> enqueuePosition(Position position) async {
    final credentials = await _localStore.readCredentials();
    if (!credentials.canSend) return false;

    await _localStore.enqueue(
      DailyRouteLocationRecord.fromPosition(
        position,
        employeeId: credentials.employeeId!,
      ),
    );
    return true;
  }

  Future<int> flushPending() async {
    if (_isFlushing) return 0;
    _isFlushing = true;

    try {
      var credentials = await _localStore.readCredentials();
      if (!credentials.canSend) return 0;

      final records = await _localStore.readPendingRecords();
      final batch = records
          .where((record) => record.employeeId == credentials.employeeId)
          .toList();
      batch.sort((a, b) => a.capturedAt.compareTo(b.capturedAt));
      if (batch.isEmpty) return 0;

      var result = await _remoteClient.sendDailyRoute(
        credentials: credentials,
        records: batch,
      );

      if (result == DailyRouteSendResult.unauthorized &&
          credentials.refreshToken.isNotEmpty) {
        final refreshed = await _remoteClient.refreshToken(
          credentials.refreshToken,
        );
        if (refreshed != null) {
          await _localStore.saveTokens(refreshed);
          credentials = credentials.copyWith(
            accessToken: refreshed.accessToken,
            refreshToken: refreshed.refreshToken,
          );
          result = await _remoteClient.sendDailyRoute(
            credentials: credentials,
            records: batch,
          );
        }
      }

      if (result != DailyRouteSendResult.success) {
        return 0;
      }

      for (final record in batch) {
        await _localStore.deletePendingRecord(record.id);
      }
      return batch.length;
    } finally {
      _isFlushing = false;
    }
  }
}

abstract class DailyRouteLocalStore {
  Future<DailyRouteCredentials> readCredentials();
  Future<void> saveTokens(DailyRouteTokenPair tokens);
  Future<void> enqueue(DailyRouteLocationRecord record);
  Future<List<DailyRouteLocationRecord>> readPendingRecords();
  Future<void> deletePendingRecord(String id);
}

class DailyRouteHiveLocalStore implements DailyRouteLocalStore {
  Box? _apiBox;
  Box? _queueBox;

  Future<void> init() async {
    final dir = await getApplicationDocumentsDirectory();
    Hive.init('${dir.path}/crm_imv');
    _apiBox = Hive.isBoxOpen(_apiBoxName)
        ? Hive.box(_apiBoxName)
        : await Hive.openBox(_apiBoxName);
    _queueBox = Hive.isBoxOpen(_queueBoxName)
        ? Hive.box(_queueBoxName)
        : await Hive.openBox(_queueBoxName);
  }

  Box get _api {
    final box = _apiBox;
    if (box == null) {
      throw StateError('DailyRouteHiveLocalStore.init() must be called first');
    }
    return box;
  }

  Box get _queue {
    final box = _queueBox;
    if (box == null) {
      throw StateError('DailyRouteHiveLocalStore.init() must be called first');
    }
    return box;
  }

  @override
  Future<DailyRouteCredentials> readCredentials() async {
    return DailyRouteCredentials(
      accessToken: _readString(_accessTokenKey),
      refreshToken: _readString(_refreshTokenKey),
      employeeId: _readInt(_employeeIdKey),
    );
  }

  @override
  Future<void> saveTokens(DailyRouteTokenPair tokens) async {
    await _api.put(_accessTokenKey, tokens.accessToken);
    await _api.put(_refreshTokenKey, tokens.refreshToken);
  }

  @override
  Future<void> enqueue(DailyRouteLocationRecord record) async {
    await _queue.put(record.id, record.toJson());
  }

  @override
  Future<List<DailyRouteLocationRecord>> readPendingRecords() async {
    final records = <DailyRouteLocationRecord>[];
    for (final value in _queue.values) {
      final map = _toStringKeyedMap(value);
      if (map == null) continue;
      final record = DailyRouteLocationRecord.fromJson(map);
      if (record != null) records.add(record);
    }
    records.sort((a, b) => a.capturedAt.compareTo(b.capturedAt));
    return records;
  }

  @override
  Future<void> deletePendingRecord(String id) async {
    await _queue.delete(id);
  }

  String _readString(String key, {String defaultValue = ''}) {
    final value = _api.get(key, defaultValue: defaultValue) ?? defaultValue;
    return value.toString();
  }

  int? _readInt(String key) {
    final value = _api.get(key);
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    return null;
  }

  Map<String, dynamic>? _toStringKeyedMap(Object? value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) {
      return value.map((key, value) => MapEntry(key.toString(), value));
    }
    return null;
  }
}

abstract class DailyRouteRemoteClient {
  Future<DailyRouteSendResult> sendDailyRoute({
    required DailyRouteCredentials credentials,
    required List<DailyRouteLocationRecord> records,
  });

  Future<DailyRouteTokenPair?> refreshToken(String refreshToken);
}

class DailyRouteDioRemoteClient implements DailyRouteRemoteClient {
  DailyRouteDioRemoteClient({Dio? dio})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              baseUrl: _baseUrl,
              connectTimeout: const Duration(seconds: 60),
              receiveTimeout: const Duration(seconds: 60),
              sendTimeout: const Duration(seconds: 60),
            ),
          );

  final Dio _dio;

  @override
  Future<DailyRouteSendResult> sendDailyRoute({
    required DailyRouteCredentials credentials,
    required List<DailyRouteLocationRecord> records,
  }) async {
    final url = '${_dio.options.baseUrl}directory/save-location/';
    _log(
      'sendDailyRoute: POST $url count=${records.length} '
      'body=${records.map((record) => record.toRequestBody()).toList()}',
    );
    try {
      final response = await _dio.post<dynamic>(
        'directory/save-location/',
        data: records.map((record) => record.toRequestBody()).toList(),
        options: Options(
          contentType: Headers.jsonContentType,
          headers: {'Authorization': 'Bearer ${credentials.accessToken}'},
          validateStatus: (_) => true,
        ),
      );

      final statusCode = response.statusCode ?? 0;
      _log('sendDailyRoute: status=$statusCode body=${response.data}');
      if (statusCode >= 200 && statusCode < 300) {
        return DailyRouteSendResult.success;
      }
      if (statusCode == 401) {
        return DailyRouteSendResult.unauthorized;
      }
      return DailyRouteSendResult.retryableFailure;
    } on DioException catch (e) {
      _log(
        'sendDailyRoute: DioException ${e.type} ${e.response?.statusCode} ${e.message}',
      );
      if (e.response?.statusCode == 401) {
        return DailyRouteSendResult.unauthorized;
      }
      return DailyRouteSendResult.retryableFailure;
    }
  }

  @override
  Future<DailyRouteTokenPair?> refreshToken(String refreshToken) async {
    try {
      final response = await _dio.post<dynamic>(
        'user/token/refresh/',
        data: {'refresh': refreshToken},
        options: Options(
          contentType: Headers.jsonContentType,
          extra: {'no_token': true},
          validateStatus: (_) => true,
        ),
      );

      final statusCode = response.statusCode ?? 0;
      final data = response.data;
      if (statusCode < 200 || statusCode >= 300 || data is! Map) {
        return null;
      }

      final access = data['access']?.toString() ?? '';
      final refresh = data['refresh']?.toString() ?? refreshToken;
      if (access.isEmpty) return null;

      return DailyRouteTokenPair(accessToken: access, refreshToken: refresh);
    } on DioException {
      return null;
    }
  }
}

enum DailyRouteSendResult { success, unauthorized, retryableFailure }

class DailyRouteCredentials {
  const DailyRouteCredentials({
    required this.accessToken,
    required this.refreshToken,
    required this.employeeId,
  });

  final String accessToken;
  final String refreshToken;
  final int? employeeId;

  bool get canSend => accessToken.isNotEmpty && employeeId != null;

  DailyRouteCredentials copyWith({
    String? accessToken,
    String? refreshToken,
    int? employeeId,
  }) {
    return DailyRouteCredentials(
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      employeeId: employeeId ?? this.employeeId,
    );
  }
}

class DailyRouteTokenPair {
  const DailyRouteTokenPair({
    required this.accessToken,
    required this.refreshToken,
  });

  final String accessToken;
  final String refreshToken;
}

class DailyRouteLocationRecord {
  DailyRouteLocationRecord({
    required this.id,
    required this.employeeId,
    required this.routeDate,
    required this.capturedAt,
    required this.latitude,
    required this.longitude,
    required this.speed,
    required this.accuracy,
  });

  final String id;
  final int employeeId;
  final String routeDate;
  final DateTime capturedAt;
  final double latitude;
  final double longitude;
  final double speed;
  final double accuracy;

  factory DailyRouteLocationRecord.fromPosition(
    Position position, {
    required int employeeId,
  }) {
    final capturedAt = position.timestamp.toLocal();
    return DailyRouteLocationRecord(
      id: '${employeeId}_${capturedAt.microsecondsSinceEpoch}_${Random.secure().nextInt(1 << 32)}',
      employeeId: employeeId,
      routeDate: _formatDate(capturedAt),
      capturedAt: capturedAt,
      latitude: position.latitude,
      longitude: position.longitude,
      speed: position.speed.isFinite && position.speed > 0 ? position.speed : 0,
      accuracy: position.accuracy.isFinite ? position.accuracy : 0,
    );
  }

  static DailyRouteLocationRecord? fromJson(Map<String, dynamic> json) {
    final id = json['id']?.toString();
    final employeeId = _parseInt(json['employee_id']);
    final routeDate = json['route_date']?.toString();
    final capturedAt = DateTime.tryParse(json['captured_at']?.toString() ?? '');
    final latitude = _parseDouble(json['latitude']);
    final longitude = _parseDouble(json['longitude']);
    final speed = _parseDouble(json['speed']);
    final accuracy = _parseDouble(json['accuracy']);

    if (id == null ||
        id.isEmpty ||
        employeeId == null ||
        routeDate == null ||
        routeDate.isEmpty ||
        capturedAt == null ||
        latitude == null ||
        longitude == null ||
        speed == null ||
        accuracy == null) {
      return null;
    }

    return DailyRouteLocationRecord(
      id: id,
      employeeId: employeeId,
      routeDate: routeDate,
      capturedAt: capturedAt,
      latitude: latitude,
      longitude: longitude,
      speed: speed,
      accuracy: accuracy,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'employee_id': employeeId,
    'route_date': routeDate,
    'captured_at': capturedAt.toIso8601String(),
    'latitude': latitude,
    'longitude': longitude,
    'speed': speed,
    'accuracy': accuracy,
  };

  Map<String, dynamic> toRequestBody() => {
    'latitude': latitude,
    'longitude': longitude,
    'timestamp': _formatDateTime(capturedAt.toLocal()),
  };

  static int? _parseInt(Object? value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    return null;
  }

  static double? _parseDouble(Object? value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }
}

String _formatDate(DateTime date) {
  final year = date.year.toString().padLeft(4, '0');
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  return '$year-$month-$day';
}

String _formatDateTime(DateTime date) {
  final year = date.year.toString().padLeft(4, '0');
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  final hour = date.hour.toString().padLeft(2, '0');
  final minute = date.minute.toString().padLeft(2, '0');
  return '$year-$month-$day $hour:$minute';
}
