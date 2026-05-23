import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginButton extends StatelessWidget {
  const LoginButton({
    super.key,
    required this.title,
    required this.isEnabled,
    required this.isLoading,
    required this.onPressed,
  });

  static const _enabledBackground = Color(0xFF314692);
  static const _disabledBackground = Color(0xFFF4F4F4);
  static const _enabledText = Color(0xFFFCFCFC);
  static const _disabledText = Color(0xFFBBBBBB);

  final String title;
  final bool isEnabled;
  final bool isLoading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final canTap = isEnabled && !isLoading;

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: Material(
        color: canTap ? _enabledBackground : _disabledBackground,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: canTap ? onPressed : null,
          child: Center(
            child: isLoading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(_disabledText),
                    ),
                  )
                : Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.manrope(
                      color: canTap ? _enabledText : _disabledText,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      height: 24 / 15,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
