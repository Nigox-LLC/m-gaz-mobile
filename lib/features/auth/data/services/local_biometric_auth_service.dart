import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:injectable/injectable.dart';
import 'package:local_auth/local_auth.dart';

import '../../domain/services/biometric_auth_service.dart';

@LazySingleton(as: BiometricAuthService)
class LocalBiometricAuthService implements BiometricAuthService {
  LocalBiometricAuthService() : _authentication = LocalAuthentication();

  @visibleForTesting
  LocalBiometricAuthService.withAuthentication(this._authentication);

  final LocalAuthentication _authentication;
  bool _promptInProgress = false;

  @override
  Future<BiometricAvailability> availability() async {
    try {
      if (!await _authentication.isDeviceSupported()) {
        return BiometricAvailability.notSupported;
      }
      return (await _authentication.getAvailableBiometrics()).isEmpty
          ? BiometricAvailability.notEnrolled
          : BiometricAvailability.available;
    } on PlatformException catch (error) {
      return _availabilityFromCode(error.code);
    } catch (_) {
      return BiometricAvailability.unavailable;
    }
  }

  @override
  Future<BiometricResult> authenticate({required String reason}) async {
    if (_promptInProgress) return BiometricResult.unavailable;
    _promptInProgress = true;
    try {
      final authenticated = await _authentication.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );
      return authenticated ? BiometricResult.success : BiometricResult.canceled;
    } on PlatformException catch (error) {
      final code = error.code.toLowerCase();
      if (code.contains('cancel')) return BiometricResult.canceled;
      if (code.contains('lockout')) return BiometricResult.lockedOut;
      if (code.contains('notavailable') || code.contains('notenrolled')) {
        return BiometricResult.unavailable;
      }
      return BiometricResult.failed;
    } catch (_) {
      return BiometricResult.failed;
    } finally {
      _promptInProgress = false;
    }
  }

  BiometricAvailability _availabilityFromCode(String code) {
    final normalized = code.toLowerCase();
    if (normalized.contains('notenrolled')) {
      return BiometricAvailability.notEnrolled;
    }
    if (normalized.contains('nobiometrichardware')) {
      return BiometricAvailability.notSupported;
    }
    return BiometricAvailability.unavailable;
  }
}
