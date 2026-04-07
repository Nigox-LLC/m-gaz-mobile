import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:keyboard_dismisser/keyboard_dismisser.dart';
import 'package:m_gaz/ui/auth/attendance/bloc/attendance_bloc.dart';
import 'package:m_gaz/ui/home/tasks/bloc/task_bloc.dart';
import 'package:m_gaz/ui/home/working-with-stamps/bloc/working_with_stamps_bloc.dart';
import '../di.dart';
import '../global_bloc/global_bloc.dart';
import '../ui/auth/login/bloc/login_bloc.dart';
import '../ui/home/measurement_devices/grs_measurement_devices/bloc/grs_measurement_devices_bloc.dart';
import '../ui/home/measurement_devices/technological-measuring/bloc/tech_measures_bloc.dart';
import '../ui/home/working_with_consumers/bloc/consumer_relations_bloc.dart';

class MainApp extends StatelessWidget {
  const MainApp({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<LoginBloc>(create: (context) => LoginBloc()),
        BlocProvider<ConsumerRelationsBloc>(
          create: (context) => ConsumerRelationsBloc(),
        ),
        BlocProvider<GlobalBloc>(create: (context) => GlobalBloc()),
        BlocProvider<TechMeasuresBloc>(create: (context) => di.get<TechMeasuresBloc>()),
        BlocProvider<TaskBloc>(create: (context) => TaskBloc()),
        BlocProvider<AttendanceBloc>(create: (context) => AttendanceBloc()),
        BlocProvider<WorkingWithStampBloc>(
          create: (context) => WorkingWithStampBloc(),
        ),
        BlocProvider<GrsMeasurementDevicesBloc>(
          create: (context) => GrsMeasurementDevicesBloc(),
        ),
      ],
      child: EasyLocalization(
        supportedLocales: const [
          Locale('uz', 'UZ'), // Uzbek Latin
          Locale('ru', 'RU'), // Russian
          Locale('en', 'EN'), // English
          Locale('uz', 'Cyrl'), // Uzbek Cyrillic
        ],
        path: 'assets/tr',
        saveLocale: true,
        useOnlyLangCode: false,
        startLocale: Locale('uz', 'UZ'),
        fallbackLocale: Locale('uz', 'UZ'),
        child: KeyboardDismisser(
          gestures: const [GestureType.onTap],
          child: child,
        ),
      ),
    );
  }
}
