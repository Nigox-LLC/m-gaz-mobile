import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:m_gaz/core/extension/size_extension.dart';
import 'package:m_gaz/ui/home/profile/pages/setting/widget/language.dart';

import '../../../../../core/common/words.dart';
import '../../../../../core/utils/colors.dart';
import '../../../../../core/utils/style.dart';
import '../../../../../global_widget/app_tools.dart';
import '../../../../../global_widget/global_app_bar.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool supportBiometric = false;
  bool availableBiometricEnter = false;
  bool hasBiometric = false;

  @override
  void initState() {
    super.initState();
    _initBiometric();
  }

  Future<void> _initBiometric() async {
    final localAuth = LocalAuthentication();
    final isSupported = await localAuth.isDeviceSupported();
    final available = await localAuth.getAvailableBiometrics();

    if (!mounted) return;
    setState(() {
      supportBiometric = isSupported;
      hasBiometric = available.isNotEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    final selectedLangName = languageNameFromId(
      languageIdFromLocale(context.locale),
    );

    return Scaffold(
      backgroundColor: AppColors.cF5F5F5,
      appBar: CustomGlobalAppBar(title: Words.settings.tr()),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 16.h),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.w),
            color: AppColors.white,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _settingTile(
                icon: AppTools.language,
                title: Words.appLanguage.tr(),
                trailing: Text(
                  selectedLangName,
                  style: AppTextStyles.style600.copyWith(
                    fontSize: 14.w,
                    color: AppColors.c717680,
                  ),
                ),
                onTap: () async {
                  final result = await showModalBottomSheet<String>(
                    context: context,
                    isScrollControlled: true,
                    builder: (_) => const LanguageBottomSheet(),
                  );

                  if (result != null && mounted) {
                    await context.setLocale(localeFromLanguageId(result));
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _settingTile({
    required String icon,
    required String title,
    required Widget trailing,
    VoidCallback? onTap,
  }) {
    return Material(
      borderRadius: BorderRadius.circular(16.w),
      color: AppColors.white,
      child: InkWell(
        borderRadius: BorderRadius.circular(16.w),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 8.w),
          child: Row(
            children: [
              AppTools.svg(
                icon,
                colorFilter: ColorFilter.mode(
                  AppColors.cFF692E,
                  BlendMode.srcIn,
                ),
                height: 24.h,
              ),
              10.getW(),
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyles.style600.copyWith(
                    fontSize: 14.w,
                    color: AppColors.black,
                  ),
                ),
              ),
              trailing,
            ],
          ),
        ),
      ),
    );
  }
}
