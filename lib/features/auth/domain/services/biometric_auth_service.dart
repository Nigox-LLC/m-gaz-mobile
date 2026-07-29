enum BiometricAvailability {
  unknown,
  available,
  notSupported,
  notEnrolled,
  unavailable,
}

enum BiometricResult { success, canceled, failed, lockedOut, unavailable }

abstract class BiometricAuthService {
  Future<BiometricAvailability> availability();

  Future<BiometricResult> authenticate({required String reason});
}
