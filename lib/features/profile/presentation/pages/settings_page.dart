import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:m_gaz/core/common/words.dart';
import 'package:m_gaz/features/profile/presentation/widgets/language_bottom_sheet.dart';
import 'package:m_gaz/features/profile/presentation/widgets/personal_data_item.dart';

import '../../../../global_widget/app_tools.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  String _languageLabel(Locale locale) {
    if (locale == const Locale('uz', 'Cyrl')) return "O‘zbekcha(krill)";
    if (locale == const Locale('ru', 'RU')) return "Русский";
    return "O‘zbekcha";
  }

  String _languageFlag(Locale locale) {
    if (locale == const Locale('ru', 'RU')) return AppTools.icFlagRu;
    return AppTools.flagUz;
  }

  @override
  Widget build(BuildContext context) {
    final locale = context.locale;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFFCFCFC),
        elevation: 0,
        title: Text(
          Words.settings.tr(),
          style: GoogleFonts.manrope(fontSize: 17, fontWeight: FontWeight.w800, color: Color(0xFF1A1D2E)),
        ),
        leading: IconButton(onPressed: () => Navigator.pop(context), icon: AppTools.svg(AppTools.icChervonLeft), iconSize: 24),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            PersonalDataItem(
              label: Words.changeLanguage.tr(),
              text: _languageLabel(locale),
              prefixWidget: AppTools.svg(_languageFlag(locale), width: 24, height: 16),
              suffixWidget: AppTools.svg(AppTools.icCheckCircle),
              isBorder: false,
              enableBorderRadius: 24,
              fillColor: Color(0xFFF0F0F0),
              onTap: () => LanguageBottomSheet.show(context),
            ),
          ],
        ),
      ),
    );
  }
}
