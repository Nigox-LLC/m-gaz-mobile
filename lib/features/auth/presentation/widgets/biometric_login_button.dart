import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:m_gaz/core/utils/colors.dart';
import 'package:m_gaz/global_widget/app_tools.dart';

class BiometricLoginButton extends StatelessWidget {
  const BiometricLoginButton({
    super.key,
    required this.title,
    required this.isEnabled,
    required this.isLoading,
    required this.onPressed,
  });

  final String title;
  final bool isEnabled;
  final bool isLoading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final canTap = isEnabled && !isLoading;
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: Material(
        color: AppColors.biometricButton,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.biometricBorder),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: canTap ? onPressed : null,
          child: Center(
            child: isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation(Colors.white),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.manrope(
                          color: const Color(0xFFFCFCFC),
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          height: 24 / 15,
                        ),
                      ),
                      const SizedBox(width: 8),
                      AppTools.svg(
                        AppTools.biometricFaceId,
                        width: 20,
                        height: 20,
                        colorFilter: const ColorFilter.mode(
                          Color(0xFFFCFCFC),
                          BlendMode.srcIn,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
