import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:m_gaz/ui/home/profile/pages/profile_info/profile_info_screen.dart';
import 'package:m_gaz/ui/home/profile/pages/setting/setting.dart';
import 'package:m_gaz/ui/home/profile/widget/row_item.dart';
import '../../../core/common/words.dart';
import '../../../core/extension/navigator_extension.dart';
import '../../../core/extension/size_extension.dart';
import '../../../core/utils/colors.dart';
import '../../../global_widget/app_tools.dart';
import '../../auth/login/bloc/login_bloc.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<LoginBloc>().state.user;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarBrightness: Brightness.light, // iOS uchun
        statusBarIconBrightness: Brightness.light, // Android uchun ikonlar qora
      ),
      child: Scaffold(
        backgroundColor: AppColors.cF5F5F5,
        body: SingleChildScrollView(
          child: Column(
            children: [
              /// Header (Gradient qismi)
              Container(
                height: MediaQuery.of(context).size.height / 3,
                padding: const EdgeInsets.all(20),
                width: double.infinity,
                decoration: const BoxDecoration(
                  gradient: AppColors.catalogGradient,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    80.getH(),
                    Center(child: SvgPicture.asset(AppTools.person, width: 80)),
                    const SizedBox(height: 20),
                    Center(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user?.username ?? Words.user.tr(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 5),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              20.getH(),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 8.h,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(16.w),
                  ),
                  child: Column(
                    children: [
                      ProfileRowItem(
                        iconPath: AppTools.user,
                        title: Words.personalInfo.tr(),
                        callback: () => push(const ProfileInfoScreen()),
                      ),
                      ProfileRowItem(
                        iconPath: AppTools.agreement,
                        title: Words.reports.tr(),
                        callback: () {},
                      ),
                    ],
                  ),
                ),
              ),
              24.getH(),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 8.h,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(16.w),
                  ),
                  child: Column(
                    children: [
                      ProfileRowItem(
                        iconPath: AppTools.settings,
                        title: Words.settings.tr(),
                        callback: () => push(SettingsScreen()),
                      ),
                    ],
                  ),
                ),
              ),
              100.getH(),
            ],
          ),
        ),
      ),
    );
  }
}
