import 'package:easy_localization/easy_localization.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:m_gaz/core/api/base/base_api.dart';
import 'package:m_gaz/features/auth/presentation/pages/login_screen.dart';
import 'package:m_gaz/ui/auth/splash/splash_screen.dart';
import 'package:m_gaz/ui/home/home_screen.dart';
import 'package:thunder/thunder.dart';
import 'app/app.dart';
import 'app/injection.dart';
import 'core/common/words.dart';
import 'core/extension/size_extension.dart';
import 'core/utils/themes.dart';
import 'di.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  // FlutterBackgroundService.initialize(onStart);
  await setup();
  await configureDependencies();
  runApp(const MainApp(child: MyApp()));
}

void onStart(ServiceInstance service) {
  if (service is AndroidServiceInstance) {
    service.setForegroundNotificationInfo(
      title: Words.roadObserver.tr(),
      content: Words.running.tr(),
    );
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  // Ilova orqa fonga (paused/hidden) o'tganini belgilaydi. Faqat shu holatdan
  // keyin resumed bo'lganda login majburlanadi (vaqtinchalik inactive emas).
  bool _wentBackground = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden) {
      _wentBackground = true;
    } else if (state == AppLifecycleState.resumed && _wentBackground) {
      _wentBackground = false;
      _forceLogin();
    }
  }

  // Orqa fondan qaytganda login ekraniga majburiy o'tish. Stack tozalanadi,
  // LoginScreen.initState username'ni avto-to'ldiradi.
  void _forceLogin() {
    final nav = mainKey.currentState;
    if (nav == null) return;
    final current = ModalRoute.of(nav.context)?.settings.name;
    if (current == '/login') return; // allaqachon login — flicker oldini olamiz
    nav.pushNamedAndRemoveUntil('/login', (route) => false);
  }

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
