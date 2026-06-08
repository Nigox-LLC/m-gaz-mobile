import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/extension/size_extension.dart';
import '../../../core/hive/api_hive.dart';
import '../../../core/utils/colors.dart';
import '../../../core/utils/style.dart';
import '../../../di.dart';
import '../../../global_widget/app_tools.dart';
import '../../../features/auth/presentation/pages/login_screen.dart';
import '../../home/home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  // Sessiya oynasi: ilova oxirgi marta faol bo'lgandan beri shu muddatdan kam
  // vaqt o'tgan bo'lsa va token saqlangan bo'lsa, login so'ralmaydi — to'g'ridan
  // Home ochiladi. Aks holda (token yo'q yoki 5 daqiqadan ko'p o'tgan) login.
  static const Duration _sessionTimeout = Duration(minutes: 5);

  Future<void> _checkAuth() async {
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;

    final hive = di.get<ApiHive>();
    final hasToken = hive.accessToken.isNotEmpty;
    final lastActive = hive.lastActiveMillis;
    final elapsed = DateTime.now().millisecondsSinceEpoch - lastActive;
    final sessionAlive =
        lastActive > 0 && elapsed < _sessionTimeout.inMilliseconds;

    if (hasToken && sessionAlive) {
      _goHome();
    } else {
      _goLogin();
    }
  }

  void _goHome() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => HomeScreen()),
    );
  }

  void _goLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarBrightness: Brightness.light,
        statusBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(child: AppTools.img(AppTools.appIcon, height: 220.h)),
            ShaderMask(
              shaderCallback: (bounds) => LinearGradient(
                colors: [
                  AppColors.white,
                  AppColors.white.withValues(alpha: 0.7),
                ],
              ).createShader(bounds),
              child: Text(
                "M-GAZ",
                style: AppTextStyles.style700.copyWith(
                  fontSize: 32.w,
                  letterSpacing: 3,
                  color: AppColors.white,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.c181D27,
      ),
    );
  }
}
