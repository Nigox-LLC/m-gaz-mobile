import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:m_gaz/core/api/attendance/attendance_api.dart';
import 'package:m_gaz/core/api/global/global_api.dart';
import 'package:m_gaz/core/api/task/task_api.dart';
import 'package:m_gaz/core/api/tech_measure_api/tech_measure_api.dart';
import 'package:m_gaz/core/api/working-with-stamps/working_with_stamps_api.dart';
import 'package:m_toast/m_toast.dart';
import 'core/api/base/base_api.dart';
import 'core/api/grs/grs_measurement_api.dart';
import 'core/api/user/user_api.dart';
import 'core/api/working_with_consumers_api/consumer_relations_api.dart';
import 'core/hive/api_hive.dart';
import 'core/hive/hive_base.dart';
import 'core/storage/local_storage.dart';

final di = GetIt.instance;
final mainKey = GlobalKey<NavigatorState>();
final toast = ShowMToast(mainKey.currentContext!);

Future<void> setup() async {
  await _setupInit();
  await _setupFactory();
  await StorageRepository.getInstance();
}

Future<void> _setupInit() async {
  await EasyLocalization.ensureInitialized();
  EasyLocalization.logger.enableLevels = [];

  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle.dark.copyWith(
      statusBarColor: Colors.black,
      systemNavigationBarColor: Colors.black,
    ),
  );
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  await SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.manual,
    overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom],
  );
}

Future<void> _setupFactory() async {
  di.registerLazySingleton(() => HiveBase());
  await di.get<HiveBase>().init();
  // di.registerLazySingleton(() => DatabaseService());
  // await di.get<DatabaseService>().database;
  di.registerLazySingleton(() => ApiHive(di.get()));
  di.registerLazySingleton(
    () => ApiBase(
      Dio(
        BaseOptions(
          baseUrl: ApiBase.baseUrl,
          connectTimeout: const Duration(seconds: 60),
          receiveTimeout: const Duration(seconds: 60),
          sendTimeout: const Duration(seconds: 60),
        ),
      ),
      di.get<ApiHive>(),
    ),
  );

  di.registerLazySingleton(() => UserApi(di.get()));
  di.registerLazySingleton(() => ConsumerRelationsApi(di.get()));
  di.registerLazySingleton(() => GlobalApi(di.get()));
  di.registerLazySingleton(() => TechMeasureApi(di.get<ApiBase>()));
  di.registerLazySingleton(() => TaskApi(di.get()));
  di.registerLazySingleton(() => AttendanceApi(di.get()));
  // di.registerLazySingleton(() => EGXUApi(di.get()));
  di.registerLazySingleton(() => WorkingWithStampsApi(di.get()));
  di.registerLazySingleton(() => GrsMeasurementDevicesApi(di.get()));


  // di.registerFactory(() => TechMeasuresBloc());
}
