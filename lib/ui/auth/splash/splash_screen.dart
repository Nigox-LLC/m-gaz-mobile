import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/extension/size_extension.dart';
import '../../../core/utils/colors.dart';
import '../../../core/utils/style.dart';
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

  // Har ilova ishga tushganda login sahifasi ochiladi. Avto-login (token orqali)
  // olib tashlandi — foydalanuvchi har safar parolni o‘zi kiritadi, username esa
  // login ekranida avto-to‘ladi. Yuz tekshiruvi login muvaffaqiyatidan keyin
  // kuniga bir marta (requiresDailyAgreement) so‘raladi.
  Future<void> _checkAuth() async {
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    _goLogin();
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
