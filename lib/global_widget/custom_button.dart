import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:m_gaz/core/extension/size_extension.dart';
import '../core/utils/colors.dart';
import '../core/utils/style.dart';
import 'app_tools.dart';

class CustomButton extends StatelessWidget {
  final String title;
  final VoidCallback? onTap;
  final Color backgroundColor;
  final Color textColor;
  final int borderRadius;
  final int fontSize;
  final FontWeight fontWeight;
  final EdgeInsetsGeometry padding;
  final BoxBorder? border;
  final bool isFocusNot;
  final bool isLoading;
  final bool isEnabled;
  final Widget? loadingIndicator;
  final Color? loadingColor;
  final String? icon;
  final Color? iconColor;

  /// Yangi qo‘shildi
  final Gradient? backgroundGradient;

  const CustomButton({
    super.key,
    required this.title,
    this.onTap,
    this.backgroundColor = AppColors.c1570EF,
    this.textColor = AppColors.white,
    this.borderRadius = 12,
    this.fontSize = 16,
    this.fontWeight = FontWeight.w500,
    this.padding = const EdgeInsets.symmetric(vertical: 14),
    this.border,
    this.isFocusNot = false,
    this.isLoading = false,
    this.isEnabled = true,
    this.loadingIndicator,
    this.loadingColor,
    this.icon,
    this.iconColor,
    this.backgroundGradient,
  });

  @override
  Widget build(BuildContext context) {
    final bool isWhiteBackground = backgroundColor == AppColors.white;
    final bool isDisabled = !isEnabled || isLoading;

    Color currentBackgroundColor =
        isFocusNot ? const Color(0xFFFDFDFD) : backgroundColor;
    Color currentTextColor = isFocusNot ? const Color(0xFFA4A7AE) : textColor;

    if (isDisabled) {
      currentBackgroundColor = currentBackgroundColor.withValues(alpha: 0.6);
      currentTextColor = currentTextColor.withValues(alpha: 0.6);
    }

    final Color finalTextColor =
        isWhiteBackground ? AppColors.black : currentTextColor;
    final Color finalBorderColor =
        isWhiteBackground ? AppColors.black : currentBackgroundColor;

    return Material(
      borderRadius: BorderRadius.circular(borderRadius.w),
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(borderRadius.w),
        onTap: isDisabled ? null : onTap,
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            gradient:
                backgroundGradient, // <-- agar gradient bo‘lsa ishlatiladi
            color:
                backgroundGradient == null
                    ? currentBackgroundColor
                    : null, // gradient bo‘lmasa oddiy rang ishlaydi
            borderRadius: BorderRadius.circular(borderRadius.w),
            border:
                border ??
                Border.all(
                  color:
                      isDisabled
                          ? finalBorderColor.withValues(alpha: 0.6)
                          : finalBorderColor,
                  width: 1.0,
                ),
          ),
          child: Center(
            child:
                isLoading
                    ? loadingIndicator ??
                        SpinKitWave(
                          size: 24.w,
                          color: loadingColor ?? finalTextColor,
                        )
                    : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (icon != null) ...[
                          AppTools.svg(
                            icon!,
                            colorFilter: ColorFilter.mode(
                              iconColor ?? finalTextColor,
                              BlendMode.srcIn,
                            ),
                          ),
                          12.getW(),
                        ],
                        Text(
                          title,
                          style: AppTextStyles.style500.copyWith(
                            fontSize: fontSize.w,
                            color: finalTextColor,
                            fontWeight: fontWeight,
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
