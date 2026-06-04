import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/hive/api_hive.dart';
import '../../../../core/models/user/token_model.dart' as legacy;
import '../models/auth_token_model.dart';
import 'auth_local_data_source.dart';

/// Thin wrapper over the legacy [ApiHive] so the rest of the auth feature
/// can depend on the [AuthLocalDataSource] contract instead of Hive
/// directly.
///
/// `ApiHive` is registered by the legacy `lib/di.dart` `setup()` (which runs
/// before `configureDependencies()`). To avoid a duplicate `lazySingleton`
/// registration in the injectable graph, we resolve it from `GetIt` lazily
/// here instead of declaring it as a constructor parameter that injectable
/// would try to re-register.
@LazySingleton(as: AuthLocalDataSource)
class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  AuthLocalDataSourceImpl() : _hive = GetIt.instance.get<ApiHive>();

  final ApiHive _hive;

  @override
  Future<void> saveToken(AuthTokenModel token) {
    return _hive.putToken(
      legacy.TokenModel(
        access: token.access,
        refresh: token.refresh,
        employeeId: token.employeeId,
      ),
    );
  }

  @override
  Future<void> saveEmployeeId(int employeeId) {
    return _hive.saveEmployeeId(employeeId);
  }

  @override
  String get accessToken => _hive.accessToken;

  @override
  String get refreshToken => _hive.refreshToken;

  @override
  Future<void> clear() => _hive.clear();

  @override
  String get lastAgreementDate => _hive.lastAgreementDate;

  @override
  set lastAgreementDate(String value) => _hive.lastAgreementDate = value;

  @override
  String get savedUsername => _hive.savedUsername;

  @override
  Future<void> saveUsername(String value) => _hive.setSavedUsername(value);
}
