import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:m_gaz/core/common/words.dart';
import 'package:m_gaz/core/extension/size_extension.dart';
import 'package:m_gaz/global_widget/app_tools.dart';

/// Google Play "prominent disclosure" shown before any background-location
/// permission request. The user must explicitly accept here before the system
/// GPS permission prompt is triggered.
///
/// Returns `true` only when the user taps "Roziman". Dismissing the dialog or
/// tapping "Yo'q, rahmat" resolves to `false` (treated as no consent).
class LocationDisclosureDialog extends StatelessWidget {
  const LocationDisclosureDialog({super.key});

  static const Color _primary = Color(0xFF526ED3);
  static const Color _textPrimary = Color(0xFF202020);
  static const Color _textSecondary = Color(0xFF6B7280);

  /// Shows the disclosure and resolves to `true` when the user accepts.
  static Future<bool> show(BuildContext context) async {
    final accepted = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const LocationDisclosureDialog(),
    );
    return accepted ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: EdgeInsets.symmetric(horizontal: 20.w),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: Colors.white,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64.w,
              height: 64.w,
              decoration: BoxDecoration(
                color: _primary.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: AppTools.svg(
                  AppTools.icMapPin,
                  width: 30,
                  height: 30,
                  colorFilter: const ColorFilter.mode(
                    _primary,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
            SizedBox(height: 20.h),
            Text(
              Words.locationDisclosureTitle.tr(),
              textAlign: TextAlign.center,
              style: GoogleFonts.manrope(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: _textPrimary,
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              Words.locationDisclosureMessage.tr(),
              textAlign: TextAlign.center,
              style: GoogleFonts.manrope(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                height: 20 / 14,
                color: _textSecondary,
              ),
            ),
            SizedBox(height: 24.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primary,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  minimumSize: Size(0, 52.h),
                ),
                child: Text(
                  Words.agree.tr(),
                  style: GoogleFonts.manrope(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            SizedBox(height: 12.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(false),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF5F5F5),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  minimumSize: Size(0, 52.h),
                ),
                child: Text(
                  Words.locationDisclosureDecline.tr(),
                  style: GoogleFonts.manrope(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: _textPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
