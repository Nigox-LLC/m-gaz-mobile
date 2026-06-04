import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:m_gaz/core/common/words.dart';

import '../../../../core/extension/size_extension.dart';
import '../../../../global_widget/app_tools.dart';

class CustomLogoutDialog extends StatelessWidget {
  const CustomLogoutDialog({super.key, required this.onPressed, required this.onCancel});

  final VoidCallback onPressed;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: EdgeInsets.symmetric(horizontal: 20.w),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 24.h,
          children: [
            Text(
              Words.logoutConfirmQuestion.tr(),
              style: GoogleFonts.manrope(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF202020)),
              textAlign: TextAlign.center,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              spacing: 12.h,
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => onCancel(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFFCFCFC),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      // To'liq kenglik uchun
                      minimumSize: Size(0, 52.h),
                      // minimumSize: Size(double.infinity, 52),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      spacing: 4.h,
                      children: [
                        AppTools.svg(AppTools.icChervonLeft, colorFilter: ColorFilter.mode(Color(0xFF202020), BlendMode.srcIn)),
                        Text(
                          Words.back.tr(),
                          style: GoogleFonts.manrope(fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFF202020)),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => onPressed(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFFB3748),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      // To'liq kenglik uchun
                      minimumSize: Size(0, 52.h),
                      // minimumSize: Size(double.infinity, 52),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      spacing: 4.h,
                      children: [
                        AppTools.svg(AppTools.logout, colorFilter: ColorFilter.mode(Colors.white, BlendMode.srcIn)),
                        Text(
                          Words.logout.tr(),
                          style: GoogleFonts.manrope(fontSize: 15, fontWeight: FontWeight.w800, color: Colors.white),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
