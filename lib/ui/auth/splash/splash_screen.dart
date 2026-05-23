import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/api/user/user_api.dart';
import '../../../core/extension/size_extension.dart';
import '../../../core/utils/colors.dart';
import '../../../core/utils/style.dart';
import '../../../di.dart';
import '../../../global_widget/app_tools.dart';
import '../../../features/auth/presentation/pages/login_screen.dart';
import '../attendance/agreement_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final _api = di.get<UserApi>();
  String lastAgreementDate = "";


  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    await Future.delayed(const Duration(seconds: 1));

    final access = _api.hive.accessToken;

    if (access.isEmpty) {
      _goLogin();
      return;
    }

    var profile = await _api.loadUserProfile();

    if (profile == null) {
      final refreshed = await _api.refreshToken();

      if (!refreshed) {
        _api.hive.clear();
        _goLogin();
        return;
      }

      profile = await _api.loadUserProfile();

      if (profile == null) {
        _api.hive.clear();
        _goLogin();
        return;
      }
    }

    if (!mounted) return;

    // ⭐ CHECK AGREEMENT LOGIC
    final today = DateTime.now();
    final todayStr = "${today.year}-${today.month}-${today.day}";

    final lastDate = _api.hive.lastAgreementDate;

    if (lastDate != todayStr) {
      // bugun hali ko‘rsatilmagan
      _api.hive.lastAgreementDate = todayStr;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => AgreementPdfScreen()),
      );
    } else {
      // bugun bir marta ko‘rsatilgan → asosiy ekranga o‘tadi
      Navigator.pushReplacementNamed(context, "/home");
    }
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
