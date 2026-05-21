import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:m_gaz/core/extension/size_extension.dart';

import '../../../../../../core/common/words.dart';
import '../../../../../../core/utils/colors.dart';
import '../../../../../../core/utils/style.dart';
import '../../../../../../global_widget/app_tools.dart';
import '../../../../../../global_widget/custom_button.dart';

Locale localeFromLanguageId(String languageId) {
  switch (languageId) {
    case 'ru':
      return const Locale('ru', 'RU');
    case 'cyrl':
      return const Locale('uz', 'Cyrl');
    case 'uz':
    default:
      return const Locale('uz', 'UZ');
  }
}

String languageIdFromLocale(Locale locale) {
  if (locale.languageCode == 'ru') {
    return 'ru';
  }
  if (locale.languageCode == 'uz' &&
      (locale.scriptCode == 'Cyrl' || locale.countryCode == 'Cyrl')) {
    return 'cyrl';
  }
  return 'uz';
}

String languageNameFromId(String languageId) {
  switch (languageId) {
    case 'ru':
      return Words.ru.tr();
    case 'cyrl':
      return Words.uzCyrl.tr();
    case 'uz':
    default:
      return Words.uz.tr();
  }
}

class LanguageBottomSheet extends StatefulWidget {
  const LanguageBottomSheet({super.key});

  @override
  State<LanguageBottomSheet> createState() => _LanguageBottomSheetState();
}

class _LanguageBottomSheetState extends State<LanguageBottomSheet> {
  String? selectedCardId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    selectedCardId ??= languageIdFromLocale(context.locale);
  }

  @override
  Widget build(BuildContext context) {
    final selectedLanguageId =
        selectedCardId ?? languageIdFromLocale(context.locale);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16.w),
          topRight: Radius.circular(16.w),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Text(
                Words.chooseLanguage.tr(),
                style: AppTextStyles.style500.copyWith(
                  fontSize: 20.w,
                  color: AppColors.c101623,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: AppTools.svg(
                  AppTools.x,
                  colorFilter: ColorFilter.mode(
                    AppColors.cA4A7AE,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ],
          ),
          8.getH(),
          Container(height: 1.h, color: AppColors.cF2F5F8),
          16.getH(),
          _buildLanguageOption('uz', AppTools.uzbFlag, Words.uz.tr()),
          16.getH(),
          _buildLanguageOption('ru', AppTools.ruFlag, Words.ru.tr()),
          16.getH(),
          _buildLanguageOption(
            'cyrl',
            AppTools.uzbFlag,
            languageNameFromId('cyrl'),
          ),
          16.getH(),
          CustomButton(
            backgroundGradient: AppColors.catalogGradient,
            title: Words.save.tr(),
            onTap: () => Navigator.pop(context, selectedLanguageId),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageOption(
    String id,
    String flagAsset,
    String languageName,
  ) {
    return GestureDetector(
      onTap: () => setState(() => selectedCardId = id),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 16.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30.w),
          color: AppColors.cF5F5F5,
          border: Border.all(
            color: selectedCardId == id
                ? AppColors.cFF692E
                : Colors.transparent,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            SvgPicture.asset(flagAsset),
            12.getW(),
            Text(
              languageName,
              style: AppTextStyles.style600.copyWith(
                fontSize: 14.w,
                color: AppColors.c414651,
              ),
            ),
            const Spacer(),
            Radio<String>(
              value: id,
              groupValue: selectedCardId,
              onChanged: (value) {
                setState(() => selectedCardId = value);
              },
              activeColor: AppColors.cFF692E,
            ),
          ],
        ),
      ),
    );
  }
}
