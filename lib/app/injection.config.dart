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
import '../features/auth/data/datasources/auth_local_data_source.dart' as _i109;
import '../features/auth/data/datasources/auth_local_data_source_impl.dart'
    as _i889;
import '../features/auth/data/datasources/auth_remote_data_source.dart'
    as _i719;
import '../features/auth/data/datasources/auth_remote_data_source_impl.dart'
    as _i902;
import '../features/auth/data/repositories/auth_repository_impl.dart' as _i570;
import '../features/auth/domain/repositories/auth_repository.dart' as _i869;
import '../features/auth/domain/usecases/check_daily_agreement_usecase.dart'
    as _i339;
import '../features/auth/domain/usecases/get_saved_username_usecase.dart'
    as _i862;
import '../features/auth/domain/usecases/load_user_profile_usecase.dart'
    as _i846;
import '../features/auth/domain/usecases/login_usecase.dart' as _i406;
import '../features/auth/domain/usecases/logout_usecase.dart' as _i11;
import '../features/auth/presentation/bloc/login_bloc.dart' as _i724;
import '../features/gas_networks/data/datasources/gas_networks_remote_data_source.dart'
    as _i35;
import '../features/gas_networks/data/datasources/gas_networks_remote_data_source_impl.dart'
    as _i1072;
import '../features/gas_networks/data/repositories/gas_networks_repository_impl.dart'
    as _i307;
import '../features/gas_networks/domain/repositories/gas_networks_repository.dart'
    as _i943;
import '../features/gas_networks/domain/usecases/get_measuring_device_documents.dart'
    as _i1010;
import '../features/gas_networks/domain/usecases/load_more_measuring_device_documents.dart'
    as _i462;
import '../features/gas_networks/presentation/bloc/measurement_devices_bloc.dart'
    as _i356;
import '../features/profile/data/datasources/profile_remote_data_source.dart'
    as _i1053;
import '../features/profile/data/datasources/profile_remote_data_source_impl.dart'
    as _i535;
import '../features/profile/data/repository/profile_repository_impl.dart'
    as _i259;
import '../features/profile/domain/repository/profile_repository.dart' as _i928;
import '../features/profile/domain/usecases/load_profile_data_usecase.dart'
    as _i575;
import '../features/profile/presentation/bloc/profile_bloc.dart' as _i570;

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
  gh.lazySingleton<_i109.AuthLocalDataSource>(
    () => _i889.AuthLocalDataSourceImpl(),
  );
  gh.lazySingleton<_i6.NetworkInfo>(() => _i6.NetworkInfoImpl());
  gh.lazySingleton<_i719.AuthRemoteDataSource>(
    () => _i902.AuthRemoteDataSourceImpl(
      gh<_i510.ApiClient>(),
      gh<_i109.AuthLocalDataSource>(),
    ),
  );
  gh.lazySingleton<_i869.AuthRepository>(
    () => _i570.AuthRepositoryImpl(
      gh<_i719.AuthRemoteDataSource>(),
      gh<_i109.AuthLocalDataSource>(),
    ),
  );
  gh.lazySingleton<_i1053.ProfileRemoteDataSource>(
    () => _i535.ProfileRemoteDataSourceImpl(
      gh<_i510.ApiClient>(),
      gh<_i109.AuthLocalDataSource>(),
    ),
  );
  gh.lazySingleton<_i35.GasNetworksRemoteDataSource>(
    () => _i1072.GasNetworksRemoteDataSourceImpl(
      gh<_i510.ApiClient>(),
      gh<_i109.AuthLocalDataSource>(),
    ),
  );
  gh.factory<_i339.CheckDailyAgreementUseCase>(
    () => _i339.CheckDailyAgreementUseCase(gh<_i869.AuthRepository>()),
  );
  gh.factory<_i862.GetSavedUsernameUseCase>(
    () => _i862.GetSavedUsernameUseCase(gh<_i869.AuthRepository>()),
  );
  gh.factory<_i846.LoadUserProfileUseCase>(
    () => _i846.LoadUserProfileUseCase(gh<_i869.AuthRepository>()),
  );
  gh.factory<_i406.LoginUseCase>(
    () => _i406.LoginUseCase(gh<_i869.AuthRepository>()),
  );
  gh.factory<_i11.LogoutUseCase>(
    () => _i11.LogoutUseCase(gh<_i869.AuthRepository>()),
  );
  gh.factory<_i724.LoginBloc>(
    () => _i724.LoginBloc(
      gh<_i406.LoginUseCase>(),
      gh<_i846.LoadUserProfileUseCase>(),
      gh<_i339.CheckDailyAgreementUseCase>(),
      gh<_i862.GetSavedUsernameUseCase>(),
    ),
  );
  gh.lazySingleton<_i943.GasNetworksRepository>(
    () =>
        _i307.GasNetworksRepositoryImpl(gh<_i35.GasNetworksRemoteDataSource>()),
  );
  gh.factory<_i1010.GetMeasuringDeviceDocuments>(
    () => _i1010.GetMeasuringDeviceDocuments(gh<_i943.GasNetworksRepository>()),
  );
  gh.factory<_i462.LoadMoreMeasuringDeviceDocuments>(
    () => _i462.LoadMoreMeasuringDeviceDocuments(
      gh<_i943.GasNetworksRepository>(),
    ),
  );
  gh.lazySingleton<_i928.ProfileRepository>(
    () => _i259.ProfileRepositoryImpl(gh<_i1053.ProfileRemoteDataSource>()),
  );
  gh.factory<_i575.LoadProfileDataUseCase>(
    () => _i575.LoadProfileDataUseCase(gh<_i928.ProfileRepository>()),
  );
  gh.factory<_i356.MeasurementDevicesBloc>(
    () => _i356.MeasurementDevicesBloc(
      gh<_i1010.GetMeasuringDeviceDocuments>(),
      gh<_i462.LoadMoreMeasuringDeviceDocuments>(),
    ),
  );
  gh.factory<_i570.ProfileBloc>(
    () => _i570.ProfileBloc(gh<_i575.LoadProfileDataUseCase>()),
  );
  return getIt;
}

class _$RegisterModule extends _i491.RegisterModule {}
