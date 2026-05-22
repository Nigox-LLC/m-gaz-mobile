import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:m_gaz/core/extension/message_extension.dart';
import 'package:m_gaz/core/extension/navigator_extension.dart';
import 'package:m_gaz/core/extension/size_extension.dart';
import 'package:m_gaz/core/utils/locationService/location_service.dart';
import 'package:m_gaz/features/auth/presentation/bloc/login_bloc.dart';
import 'package:m_gaz/global_widget/app_tools.dart';
import 'package:m_gaz/ui/auth/attendance/agreement_screen.dart';
import '../../../../core/utils/colors.dart';
import '../../../../core/utils/style.dart';
import '../../../../global_widget/custom_textfield.dart';
import '../../../../ui/home/home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final userNameController = TextEditingController();
  final passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    userNameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void _login(BuildContext context) {
    if (userNameController.text.trim().isEmpty ||
        passwordController.text.trim().isEmpty) {
      showToast(context, "Iltimos, barcha maydonlarni to'ldiring");
      return;
    }

    context.read<LoginBloc>().add(
      LoginSubmitted(
        userName: userNameController.text.trim(),
        password: passwordController.text.trim(),
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
        backgroundColor: AppColors.c181D27,
        body: BlocListener<LoginBloc, LoginState>(
          listener: (context, state) {
            if (state.status == LoginStatus.fail) {
              showToast(context, state.errorMessage);
            }
            if (state.status == LoginStatus.success) {
              unawaited(DailyRouteLocationService().ensureStarted());
              if (state.requiresAgreement) {
                pushAndRemoveUntil(AgreementPdfScreen());
              } else {
                pushAndRemoveUntil(HomeScreen());
              }
            }
          },

          child: Stack(
            children: [
              SafeArea(
                child: Center(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: 24.w),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildLogoSection(),
                        40.getH(),
                        _buildModernLoginCard(),
                        32.getH(),
                        _buildVersionInfo(),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogoSection() {
    return Column(
      children: [
        24.getH(),
        Container(
          width: 120.w,
          height: 120.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.white, AppColors.white],
            ),
            border: Border.all(
              color: AppColors.white.withValues(alpha: 0.1),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.black.withValues(alpha: 0.4),
                blurRadius: 30,
                offset: Offset(0, 10.h),
              ),
            ],
          ),
          child: AppTools.img(AppTools.splashLogo),
        ),
        20.getH(),

        ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            colors: [AppColors.white, AppColors.white.withValues(alpha: 0.7)],
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

        Text(
          "Aniq hisob. Umumiy nazorat",
          style: AppTextStyles.style400.copyWith(
            fontSize: 14.w,
            color: AppColors.white.withValues(alpha: 0.6),
            letterSpacing: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildModernLoginCard() {
    return Container(
      padding: EdgeInsets.all(28.w),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(32.w),
        border: Border.all(
          color: AppColors.white.withValues(alpha: 0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.4),
            blurRadius: 40,
            offset: Offset(0, 20.h),
            spreadRadius: -10,
          ),
          BoxShadow(
            color: AppColors.c181D27.withValues(alpha: 0.3),
            blurRadius: 30,
            offset: Offset(0, 10.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Tizimga kirish",
            style: AppTextStyles.style600.copyWith(
              fontSize: 24.w,
              color: AppColors.white,
            ),
          ),
          32.getH(),

          _buildModernTextField(
            controller: userNameController,
            hint: "Foydalanuvchi nomi",
            icon: Icons.person_outline,
          ),
          14.getH(),

          _buildModernTextField(
            controller: passwordController,
            hint: "Parolingizni kiriting",
            icon: Icons.lock_outline,
            isPassword: true,
          ),
          20.getH(),
          10.getH(),

          BlocBuilder<LoginBloc, LoginState>(
            builder: (context, state) {
              return _buildPremiumButton(context, state);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildModernTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isPassword = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        8.getH(),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.w),
            boxShadow: [
              BoxShadow(
                color: AppColors.black.withValues(alpha: 0.2),
                blurRadius: 10,
                offset: Offset(0, 5.h),
              ),
            ],
          ),
          child: CustomTextField(
            controller: controller,
            label: hint,
            labelColor: AppColors.white,
            obscure: isPassword ? _obscurePassword : false,
            suffixIcon: isPassword
                ? IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: AppColors.white.withValues(alpha: 0.5),
                      size: 20.w,
                    ),
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  )
                : null,
          ),
        ),
      ],
    );
  }

  Widget _buildPremiumButton(BuildContext context, LoginState state) {
    return Container(
      width: double.infinity,
      height: 56.h,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.white.withValues(alpha: 0.95),
            AppColors.white.withValues(alpha: 0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(16.w),
        boxShadow: [
          BoxShadow(
            color: AppColors.white.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: Offset(0, 10.h),
          ),
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: Offset(0, 5.h),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: state.status == LoginStatus.loading
            ? null
            : () => _login(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.w),
          ),
          disabledBackgroundColor: Colors.transparent,
        ),
        child: state.status == LoginStatus.loading
            ? SizedBox(
                width: 24.w,
                height: 24.w,
                child: CircularProgressIndicator(
                  strokeWidth: 2.w,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.c181D27),
                ),
              )
            : Text(
                "Kirish",
                style: AppTextStyles.style600.copyWith(
                  fontSize: 16.w,
                  color: AppColors.c181D27,
                ),
              ),
      ),
    );
  }

  Widget _buildVersionInfo() {
    return Column(
      children: [
        Container(
          width: 40.w,
          height: 2.h,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.white.withValues(alpha: 0.1),
                AppColors.white.withValues(alpha: 0.3),
                AppColors.white.withValues(alpha: 0.1),
              ],
            ),
          ),
        ),
        12.getH(),
        Text(
          "v1.0.0",
          style: AppTextStyles.style400.copyWith(
            fontSize: 11.w,
            color: AppColors.white.withValues(alpha: 0.3),
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }
}
