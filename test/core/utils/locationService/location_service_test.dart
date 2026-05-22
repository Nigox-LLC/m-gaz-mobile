import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:m_gaz/core/utils/locationService/location_service.dart';

void main() {
  group('DailyRouteDioRemoteClient', () {
    test('sends GET with token, query parameters, and JSON body', () async {
      final adapter = _RecordingAdapter(statusCode: 200);
      final dio = Dio(BaseOptions(baseUrl: 'https://backend.m-gaz.uz/api/'))
        ..httpClientAdapter = adapter;
      final client = DailyRouteDioRemoteClient(dio: dio);
      final record = _record();

      final result = await client.sendDailyRoute(
        credentials: const DailyRouteCredentials(
          accessToken: 'access-token',
          refreshToken: 'refresh-token',
          employeeId: 1,
        ),
        record: record,
      );

      expect(result, DailyRouteSendResult.success);
      expect(adapter.lastOptions.method, 'GET');
      expect(adapter.lastOptions.path, 'directory/daily-route/');
      expect(adapter.lastOptions.queryParameters, {
        'date': '2025-11-15',
        'employee': 1,
      });
      expect(
        adapter.lastOptions.headers['Authorization'],
        'Bearer access-token',
      );
      expect(adapter.lastOptions.data, {
        'latitude': 41.3265,
        'longitude': 69.2288,
        'speed': 12.5,
        'accuracy': 5.0,
      });
    });

    test('refreshes token from refresh endpoint response', () async {
      final adapter = _RecordingAdapter(
        statusCode: 200,
        responseBody: {'access': 'new-access', 'refresh': 'new-refresh'},
      );
      final dio = Dio(BaseOptions(baseUrl: 'https://backend.m-gaz.uz/api/'))
        ..httpClientAdapter = adapter;
      final client = DailyRouteDioRemoteClient(dio: dio);

      final tokens = await client.refreshToken('old-refresh');

      expect(adapter.lastOptions.method, 'POST');
      expect(adapter.lastOptions.path, 'user/token/refresh/');
      expect(adapter.lastOptions.data, {'refresh': 'old-refresh'});
      expect(tokens?.accessToken, 'new-access');
      expect(tokens?.refreshToken, 'new-refresh');
    });
  });

  group('DailyRouteSyncEngine', () {
    test('deletes queued record after successful send', () async {
      final store = _FakeLocalStore(
        credentials: _credentials(),
        records: [_record()],
      );
      final remote = _FakeRemoteClient(
        sendResults: [DailyRouteSendResult.success],
      );
      final engine = DailyRouteSyncEngine(
        localStore: store,
        remoteClient: remote,
      );

      final sentCount = await engine.flushPending();

      expect(sentCount, 1);
      expect(store.records, isEmpty);
      expect(remote.sentRecords, hasLength(1));
    });

    test('keeps queued record when send fails', () async {
      final store = _FakeLocalStore(
        credentials: _credentials(),
        records: [_record()],
      );
      final remote = _FakeRemoteClient(
        sendResults: [DailyRouteSendResult.retryableFailure],
      );
      final engine = DailyRouteSyncEngine(
        localStore: store,
        remoteClient: remote,
      );

      final sentCount = await engine.flushPending();

      expect(sentCount, 0);
      expect(store.records, hasLength(1));
    });

    test('refreshes once on 401 and retries original record', () async {
      final store = _FakeLocalStore(
        credentials: _credentials(),
        records: [_record()],
      );
      final remote = _FakeRemoteClient(
        sendResults: [
          DailyRouteSendResult.unauthorized,
          DailyRouteSendResult.success,
        ],
        refreshResponse: const DailyRouteTokenPair(
          accessToken: 'new-access',
          refreshToken: 'new-refresh',
        ),
      );
      final engine = DailyRouteSyncEngine(
        localStore: store,
        remoteClient: remote,
      );

      final sentCount = await engine.flushPending();

      expect(sentCount, 1);
      expect(store.records, isEmpty);
      expect(store.credentials.accessToken, 'new-access');
      expect(store.credentials.refreshToken, 'new-refresh');
      expect(remote.refreshCalls, 1);
      expect(remote.sentRecords, hasLength(2));
    });

    test('does not send when token or employee id is missing', () async {
      final store = _FakeLocalStore(
        credentials: const DailyRouteCredentials(
          accessToken: '',
          refreshToken: 'refresh-token',
          employeeId: null,
        ),
        records: [_record()],
      );
      final remote = _FakeRemoteClient(
        sendResults: [DailyRouteSendResult.success],
      );
      final engine = DailyRouteSyncEngine(
        localStore: store,
        remoteClient: remote,
      );

      final sentCount = await engine.flushPending();

      expect(sentCount, 0);
      expect(store.records, hasLength(1));
      expect(remote.sentRecords, isEmpty);
    });

    test('queues position with route date and normalized speed', () async {
      final store = _FakeLocalStore(credentials: _credentials());
      final remote = _FakeRemoteClient();
      final engine = DailyRouteSyncEngine(
        localStore: store,
        remoteClient: remote,
      );

      final queued = await engine.enqueuePosition(
        Position(
          latitude: 41.3265,
          longitude: 69.2288,
          timestamp: DateTime(2025, 11, 15, 8),
          accuracy: 5,
          altitude: 0,
          altitudeAccuracy: 0,
          heading: 0,
          headingAccuracy: 0,
          speed: -1,
          speedAccuracy: 0,
        ),
      );

      expect(queued, isTrue);
      expect(store.records.single.routeDate, '2025-11-15');
      expect(store.records.single.speed, 0);
      expect(store.records.single.accuracy, 5);
    });
  });

  group('DailyRouteLocationPermissionPolicy', () {
    test('accepts whileInUse and always when credentials and service ok', () {
      expect(
        DailyRouteLocationPermissionPolicy.canStartForegroundTracking(
          credentials: _credentials(),
          serviceEnabled: true,
          permission: LocationPermission.always,
        ),
        isTrue,
      );
      expect(
        DailyRouteLocationPermissionPolicy.canStartForegroundTracking(
          credentials: _credentials(),
          serviceEnabled: true,
          permission: LocationPermission.whileInUse,
        ),
        isTrue,
      );
    });

    test('rejects denied / deniedForever / disabled service / no credentials', () {
      expect(
        DailyRouteLocationPermissionPolicy.canStartForegroundTracking(
          credentials: _credentials(),
          serviceEnabled: true,
          permission: LocationPermission.denied,
        ),
        isFalse,
      );
      expect(
        DailyRouteLocationPermissionPolicy.canStartForegroundTracking(
          credentials: _credentials(),
          serviceEnabled: true,
          permission: LocationPermission.deniedForever,
        ),
        isFalse,
      );
      expect(
        DailyRouteLocationPermissionPolicy.canStartForegroundTracking(
          credentials: _credentials(),
          serviceEnabled: false,
          permission: LocationPermission.always,
        ),
        isFalse,
      );
      expect(
        DailyRouteLocationPermissionPolicy.canStartForegroundTracking(
          credentials: const DailyRouteCredentials(
            accessToken: 'access-token',
            refreshToken: 'refresh-token',
            employeeId: null,
          ),
          serviceEnabled: true,
          permission: LocationPermission.always,
        ),
        isFalse,
      );
    });
  });

  group('DailyRouteWorkingHoursPolicy', () {
    test('isWithinWorkingHours covers 09:00 inclusive to 18:00 exclusive', () {
      expect(
        DailyRouteWorkingHoursPolicy.isWithinWorkingHours(
          DateTime(2025, 1, 1, 8, 59),
        ),
        isFalse,
      );
      expect(
        DailyRouteWorkingHoursPolicy.isWithinWorkingHours(
          DateTime(2025, 1, 1, 9),
        ),
        isTrue,
      );
      expect(
        DailyRouteWorkingHoursPolicy.isWithinWorkingHours(
          DateTime(2025, 1, 1, 12, 30),
        ),
        isTrue,
      );
      expect(
        DailyRouteWorkingHoursPolicy.isWithinWorkingHours(
          DateTime(2025, 1, 1, 17, 59),
        ),
        isTrue,
      );
      expect(
        DailyRouteWorkingHoursPolicy.isWithinWorkingHours(
          DateTime(2025, 1, 1, 18),
        ),
        isFalse,
      );
      expect(
        DailyRouteWorkingHoursPolicy.isWithinWorkingHours(
          DateTime(2025, 1, 1, 23, 0),
        ),
        isFalse,
      );
      expect(
        DailyRouteWorkingHoursPolicy.isWithinWorkingHours(
          DateTime(2025, 1, 1, 0, 0),
        ),
        isFalse,
      );
    });
  });
}

DailyRouteCredentials _credentials() {
  return const DailyRouteCredentials(
    accessToken: 'access-token',
    refreshToken: 'refresh-token',
    employeeId: 1,
  );
}

DailyRouteLocationRecord _record() {
  return DailyRouteLocationRecord(
    id: 'record-1',
    employeeId: 1,
    routeDate: '2025-11-15',
    capturedAt: DateTime(2025, 11, 15, 10),
    latitude: 41.3265,
    longitude: 69.2288,
    speed: 12.5,
    accuracy: 5,
  );
}

class _FakeLocalStore implements DailyRouteLocalStore {
  _FakeLocalStore({
    required this.credentials,
    List<DailyRouteLocationRecord>? records,
  }) : records = [...?records];

  DailyRouteCredentials credentials;
  final List<DailyRouteLocationRecord> records;

  @override
  Future<void> deletePendingRecord(String id) async {
    records.removeWhere((record) => record.id == id);
  }

  @override
  Future<void> enqueue(DailyRouteLocationRecord record) async {
    records.add(record);
  }

  @override
  Future<DailyRouteCredentials> readCredentials() async => credentials;

  @override
  Future<List<DailyRouteLocationRecord>> readPendingRecords() async {
    return [...records];
  }

  @override
  Future<void> saveTokens(DailyRouteTokenPair tokens) async {
    credentials = credentials.copyWith(
      accessToken: tokens.accessToken,
      refreshToken: tokens.refreshToken,
    );
  }
}

class _FakeRemoteClient implements DailyRouteRemoteClient {
  _FakeRemoteClient({
    List<DailyRouteSendResult>? sendResults,
    this.refreshResponse,
  }) : _sendResults = [...?sendResults];

  final List<DailyRouteSendResult> _sendResults;
  final DailyRouteTokenPair? refreshResponse;
  final List<DailyRouteLocationRecord> sentRecords = [];
  int refreshCalls = 0;

  @override
  Future<DailyRouteTokenPair?> refreshToken(String refreshToken) async {
    refreshCalls++;
    return refreshResponse;
  }

  @override
  Future<DailyRouteSendResult> sendDailyRoute({
    required DailyRouteCredentials credentials,
    required DailyRouteLocationRecord record,
  }) async {
    sentRecords.add(record);
    if (_sendResults.isEmpty) return DailyRouteSendResult.success;
    return _sendResults.removeAt(0);
  }
}

class _RecordingAdapter implements HttpClientAdapter {
  _RecordingAdapter({
    required this.statusCode,
    Map<String, dynamic>? responseBody,
  }) : responseBody = responseBody ?? const {};

  final int statusCode;
  final Map<String, dynamic> responseBody;
  late RequestOptions lastOptions;

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    lastOptions = options;
    if (requestStream != null) {
      await requestStream.drain<void>();
    }

    return ResponseBody.fromString(
      jsonEncode(responseBody),
      statusCode,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }
}
