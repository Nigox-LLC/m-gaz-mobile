import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:m_gaz/core/common/words.dart';
import 'package:m_gaz/core/utils/locationService/location_service.dart';
import 'package:permission_handler/permission_handler.dart' as ph;

/// Action the user picked in a permission-gate dialog.
enum _GateAction { grant, openSettings }

/// Blocking permission gate for daily-route background tracking.
///
/// Forces the user to grant BOTH "Allow all the time" location
/// (`LocationPermission.always`) AND battery-optimization exemption before
/// WorkManager scheduling is allowed. Without both, location stops being sent
/// once the app is killed/swiped from recents.
///
/// UI lives here so [DailyRouteLocationService] stays free of `BuildContext`.
class DailyRoutePermissionGate {
  const DailyRoutePermissionGate._();

  static final DailyRouteLocationService _service = DailyRouteLocationService();

  /// Ensures both permissions are granted, prompting with blocking dialogs as
  /// needed. Returns true only when both are granted. Returns true off-Android
  /// (the gate does not apply). Returns false if the context is disposed mid
  /// flow.
  static Future<bool> ensure(BuildContext context) async {
    if (defaultTargetPlatform != TargetPlatform.android) return true;

    final locationGranted = await _ensureAlwaysLocation(context);
    if (!locationGranted) return false;

    if (!context.mounted) return false;
    return _ensureBatteryBypass(context);
  }

  static Future<bool> _ensureAlwaysLocation(BuildContext context) async {
    var permission = await _service.requestAlwaysLocationPermission();
    while (permission != LocationPermission.always) {
      if (!context.mounted) return false;
      final action = await _showGateDialog(
        context,
        title: Words.dailyRouteAlwaysLocationTitle.tr(),
        body: Words.dailyRouteAlwaysLocationBody.tr(),
      );
      if (action == _GateAction.openSettings) {
        await ph.openAppSettings();
        permission = await Geolocator.checkPermission();
      } else {
        permission = await _service.requestAlwaysLocationPermission();
      }
    }
    return true;
  }

  static Future<bool> _ensureBatteryBypass(BuildContext context) async {
    var granted = await _service.requestBatteryOptimizationBypass();
    while (!granted) {
      if (!context.mounted) return false;
      final action = await _showGateDialog(
        context,
        title: Words.dailyRouteBatteryOptTitle.tr(),
        body: Words.dailyRouteBatteryOptBody.tr(),
      );
      if (action == _GateAction.openSettings) {
        await ph.openAppSettings();
        granted = await ph.Permission.ignoreBatteryOptimizations.isGranted;
      } else {
        granted = await _service.requestBatteryOptimizationBypass();
      }
    }
    return true;
  }

  /// Non-dismissible explainer with "Grant" (re-request) and "Open settings".
  /// Loops until the user acts; there is intentionally no cancel button.
  static Future<_GateAction> _showGateDialog(
    BuildContext context, {
    required String title,
    required String body,
  }) async {
    final action = await showDialog<_GateAction>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return PopScope(
          canPop: false,
          child: AlertDialog(
            title: Text(title),
            content: Text(body),
            actions: [
              TextButton(
                onPressed: () =>
                    Navigator.of(dialogContext).pop(_GateAction.openSettings),
                child: Text(Words.dailyRouteOpenSettings.tr()),
              ),
              FilledButton(
                onPressed: () =>
                    Navigator.of(dialogContext).pop(_GateAction.grant),
                child: Text(Words.dailyRouteGrant.tr()),
              ),
            ],
          ),
        );
      },
    );
    return action ?? _GateAction.grant;
  }
}
