// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:dio/dio.dart' as _i361;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;

import '../core/di/injection_module.dart' as _i491;
import '../core/network/api_client.dart' as _i510;
import '../core/network/network_info.dart' as _i6;

// initializes the registration of main-scope dependencies inside of GetIt
_i174.GetIt init(
  _i174.GetIt getIt, {
  String? environment,
  _i526.EnvironmentFilter? environmentFilter,
}) {
  final gh = _i526.GetItHelper(getIt, environment, environmentFilter);
  final registerModule = _$RegisterModule();
  gh.lazySingleton<_i361.Dio>(() => registerModule.dio);
  gh.lazySingleton<_i510.ApiClient>(() => _i510.ApiClient(gh<_i361.Dio>()));
  gh.lazySingleton<_i6.NetworkInfo>(() => _i6.NetworkInfoImpl());
  return getIt;
}

class _$RegisterModule extends _i491.RegisterModule {}
