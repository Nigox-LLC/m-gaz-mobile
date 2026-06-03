import 'package:easy_localization/easy_localization.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:m_gaz/core/api/base/base_api.dart';
import 'package:m_gaz/core/utils/locationService/location_service.dart';
import 'package:m_gaz/features/auth/presentation/pages/login_screen.dart';
import 'package:m_gaz/ui/auth/splash/splash_screen.dart';
import 'package:m_gaz/ui/home/home_screen.dart';
import 'package:thunder/thunder.dart';
import 'app/app.dart';
import 'app/injection.dart';
import 'core/extension/size_extension.dart';
import 'core/utils/themes.dart';
import 'di.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await DailyRouteLocationService.initializeWorkManager();
  await setup();
  await configureDependencies();
  runApp(const MainApp(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        SizeConfig.init(context);

        return MaterialApp(
          navigatorKey: mainKey,
          debugShowCheckedModeBanner: false,
          title: 'M-Gaz',
          localizationsDelegates: context.localizationDelegates,
          supportedLocales: context.supportedLocales,
          locale: context.locale,
          themeMode: ThemeMode.light,
          theme: AppThemes.theme(isDark: false),
          darkTheme: AppThemes.theme(isDark: true),
          builder: (context, child) {
            return Thunder(
              dio: [di.get<ApiBase>().dio, di.get<Dio>()],
              color: const Color(0xFF17B26A),
              child: child!,
            );
          },
          initialRoute: '/splash',
          routes: {
            '/login': (context) => LoginScreen(),
            '/home': (context) => HomeScreen(),
            '/splash': (context) => SplashScreen(),
          },
        );
      },
    );
  }
}
