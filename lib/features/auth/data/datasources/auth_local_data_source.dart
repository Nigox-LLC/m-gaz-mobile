import '../models/auth_token_model.dart';

/// Contract for the local auth storage. Wraps the underlying Hive storage so
/// the repository layer doesn't depend on Hive directly.
abstract class AuthLocalDataSource {
  Future<void> saveToken(AuthTokenModel token);
  Future<void> saveEmployeeId(int employeeId);

  String get accessToken;
  String get refreshToken;

  Future<void> clear();

  String get lastAgreementDate;
  set lastAgreementDate(String value);
}
