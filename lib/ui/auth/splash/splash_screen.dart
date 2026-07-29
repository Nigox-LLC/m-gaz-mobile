import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/extension/size_extension.dart';
import '../../../core/hive/api_hive.dart';
import '../../../core/utils/colors.dart';
import '../../../core/utils/style.dart';
import '../../../di.dart';
import '../../../global_widget/app_tools.dart';
import '../../../features/auth/presentation/pages/login_screen.dart';

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
  // Home ochiladi. Aks holda (token yo'q yoki muddat o'tgan) login.

  Future<void> _checkAuth() async {
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;

    final hive = di.get<ApiHive>();

    // Kamera/face-verification bo'limidan chiqib (yoki o'sha yerda process
    // o'lib) qaytilgan bo'lsa — token muddati ichida bo'lsa ham login majburiy.
    if (hive.pendingRelogin) {
      hive.setPendingRelogin(false);
      _goLogin();
      return;
    }

    _goLogin(autoBiometric: hive.hasStoredSession);
  }

  void _goLogin({bool autoBiometric = false}) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => LoginScreen(autoBiometric: autoBiometric),
      ),
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
