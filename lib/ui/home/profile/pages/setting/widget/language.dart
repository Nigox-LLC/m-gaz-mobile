import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:m_gaz/core/extension/size_extension.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../../../core/common/words.dart';
import '../../../../../../core/utils/colors.dart';
import '../../../../../../core/utils/style.dart';
import '../../../../../../global_widget/app_tools.dart';
import '../../../../../../global_widget/custom_button.dart';

class LanguageBottomSheet extends StatefulWidget {
  final Function(String)? onLanguageChanged;

  const LanguageBottomSheet({super.key, this.onLanguageChanged});

  @override
  State<LanguageBottomSheet> createState() => _LanguageBottomSheetState();
}

class _LanguageBottomSheetState extends State<LanguageBottomSheet> {
  String? selectedCardId = '';

  @override
  void initState() {
    super.initState();
    _loadSavedLanguage();
  }

  Future<void> _loadSavedLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLanguage =
        prefs.getString('selected_language') ?? context.locale.toString();
    setState(() {
      selectedCardId = savedLanguage;
    });
  }

  Future<void> _saveLanguage(String language) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_language', language);
  }

  void _applyLanguageChange(String language) {
    if (widget.onLanguageChanged != null) {
      widget.onLanguageChanged!(language);
    }
  }

  @override
  Widget build(BuildContext context) {
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
          _buildLanguageOption('en', AppTools.enFlag, Words.en.tr()),
          16.getH(),
          _buildLanguageOption('cyrl', AppTools.uzbFlag, "Ўзбекча"),
          16.getH(),
          CustomButton(
            backgroundGradient: AppColors.catalogGradient,
            title: Words.save.tr(),
            onTap: () async {
              await _saveLanguage(selectedCardId!);
              _applyLanguageChange(selectedCardId!);

              if (selectedCardId == 'uz') {
                await context.setLocale(const Locale('uz', 'UZ'));
              } else if (selectedCardId == 'ru') {
                await context.setLocale(const Locale('ru', 'RU'));
              } else if (selectedCardId == 'en') {
                await context.setLocale(const Locale('en', 'EN'));
              } else if (selectedCardId == 'cyrl') {
                await context.setLocale(const Locale('uz', 'Cyrl'));
              }

              Navigator.pop(context, selectedCardId);
            },
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
