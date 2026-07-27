import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:m_gaz/features/profile/presentation/widgets/personal_data_item.dart';

import '../../../../core/common/words.dart';
import '../../../../core/extension/size_extension.dart';
import '../../../../global_widget/app_tools.dart';

class SecurityPage extends StatefulWidget {
  const SecurityPage({super.key});

  @override
  State<SecurityPage> createState() => _SecurityPageState();
}

class _SecurityPageState extends State<SecurityPage> {
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFFCFCFC),
        elevation: 0,
        title: Text(
          Words.security.tr(),
          style: GoogleFonts.manrope(fontSize: 17, fontWeight: FontWeight.w800, color: Color(0xFF1A1D2E)),
        ),
        leading: IconButton(onPressed: () => Navigator.pop(context), icon: AppTools.svg(AppTools.icChervonLeft), iconSize: 24),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          spacing: 12.h,
          children: [
            PersonalDataItem(
              controller: _currentPasswordController,
              readOnly: false,
              hintText: Words.currentPasswordHint.tr(),
              label: Words.currentPassword.tr(),
              isError: false,
              suffixWidget: AppTools.svg(AppTools.icEye),
            ),
            PersonalDataItem(
              controller: _newPasswordController,
              readOnly: false,
              hintText: Words.newPasswordHint.tr(),
              label: Words.newPassword.tr(),
              suffixWidget: AppTools.svg(AppTools.icEye),
              errorText: Words.passwordsDoNotMatch.tr(),
            ),
            PersonalDataItem(
              controller: _confirmPasswordController,
              readOnly: false,
              hintText: Words.confirmPasswordHint.tr(),
              label: Words.confirmPassword.tr(),
              suffixWidget: AppTools.svg(AppTools.icEye),
              errorText: Words.passwordsDoNotMatch.tr(),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF526ED3),
            minimumSize: Size(MediaQuery.of(context).size.width, 56.h),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 8,
            children: [
              AppTools.svg(AppTools.check, colorFilter: ColorFilter.mode(Colors.white, BlendMode.srcIn)),
              Text(
                Words.save.tr(),
                style: GoogleFonts.manrope(fontSize: 15, fontWeight: FontWeight.w800, color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
