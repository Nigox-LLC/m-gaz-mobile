import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:m_gaz/core/common/words.dart';
import 'package:m_gaz/features/profile/presentation/widgets/custom_radio_widget.dart';
import 'package:m_gaz/features/profile/presentation/widgets/personal_data_item.dart';

import '../../../../core/extension/size_extension.dart';
import '../../../../global_widget/app_tools.dart';

/// Language picker bottom sheet for the settings screen. Extracted from
/// `SettingsPage` so the sheet markup lives in one reusable place.
class LanguageBottomSheet extends StatelessWidget {
  const LanguageBottomSheet({super.key});

  static const _uzCyrl = Locale('uz', 'Cyrl');
  static const _uzLatin = Locale('uz', 'UZ');
  static const _ru = Locale('ru', 'RU');

  /// Opens the language picker. Returns when the sheet is dismissed.
  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Colors.white,
      builder: (_) => const LanguageBottomSheet(),
    );
  }

  Future<void> _select(BuildContext context, Locale locale) async {
    if (context.locale != locale) {
      await context.setLocale(locale);
    }
    if (context.mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final current = context.locale;

    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 16,
          children: [
            Text(
              Words.chooseLanguage.tr(),
              style: GoogleFonts.manrope(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1A1D2E),
              ),
            ),
            Column(
              spacing: 8,
              children: [
                _LanguageTile(
                  text: "O‘zbekcha(krill)",
                  flag: AppTools.flagUz,
                  isSelected: current == _uzCyrl,
                  onTap: () => _select(context, _uzCyrl),
                ),
                _LanguageTile(
                  text: "O‘zbekcha(lotin)",
                  flag: AppTools.flagUz,
                  isSelected: current == _uzLatin,
                  onTap: () => _select(context, _uzLatin),
                ),
                _LanguageTile(
                  text: "Русский",
                  flag: AppTools.icFlagRu,
                  isSelected: current == _ru,
                  onTap: () => _select(context, _ru),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _LanguageTile extends StatelessWidget {
  const _LanguageTile({
    required this.text,
    required this.flag,
    required this.isSelected,
    required this.onTap,
  });

  final String text;
  final String flag;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PersonalDataItem(
      text: text,
      prefixWidget: AppTools.svg(flag, width: 24, height: 16),
      suffixWidget: CustomRadioWidget(isCheck: isSelected),
      isBorder: false,
      textSize: 17,
      textFontWeight: FontWeight.w500,
      textColor: const Color(0xFF04060B),
      enableBorderRadius: 24,
      fillColor: const Color(0xFFFFFFFF),
      onTap: onTap,
    );
  }
}
