import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:m_gaz/ui/auth/login/login_screen.dart';
import 'package:m_gaz/ui/auth/splash/splash_screen.dart';
import 'package:m_gaz/ui/home/home_screen.dart';
import 'app/app.dart';
import 'core/extension/size_extension.dart';
import 'core/utils/themes.dart';
import 'di.dart';

Future<void> main() async {

  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  // FlutterBackgroundService.initialize(onStart);
  await setup();
  runApp(const MainApp(child: MyApp()));
}

void onStart(ServiceInstance service) {
  if (service is AndroidServiceInstance) {
    service.setForegroundNotificationInfo(
      title: "Yo'l kuzatuvchisi",
      content: "Ishlayapti",
    );
  }
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
