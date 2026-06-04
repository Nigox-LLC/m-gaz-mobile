import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/extension/size_extension.dart';

class PersonalDataItem extends StatelessWidget {
  const PersonalDataItem({
    super.key,
    this.controller,
    this.text,
    this.textFontWeight = FontWeight.w500,
    this.textSize = 13,
    this.textColor = const Color(0xFF202020),
    this.hintText,
    this.hintTextSize = 13,
    this.hintTextFontWeight = FontWeight.w500,
    this.hintTextColor = const Color(0xFFD9D9D9),
    this.errorText,
    this.errorTextSize = 11,
    this.errorTextFontWeight = FontWeight.w500,
    this.errorTextColor = const Color(0xFFFB3748),
    this.label,
    this.enableBorderRadius,
    this.isBorder = true,
    this.suffixWidget,
    this.prefixWidget,
    this.onTap,
    this.fillColor = const Color(0xFFF9F9F9),
    this.readOnly = true,
    this.isError,
    this.maxLine,
    this.minLine = 1,
  });

  final String? label;
  final TextEditingController? controller;
  final String? text;
  final double? textSize;
  final FontWeight? textFontWeight;
  final Color? textColor;
  final String? hintText;
  final double? hintTextSize;
  final FontWeight? hintTextFontWeight;
  final Color? hintTextColor;
  final String? errorText;
  final double? errorTextSize;
  final FontWeight? errorTextFontWeight;
  final Color? errorTextColor;
  final double? enableBorderRadius;
  final bool? isBorder;
  final Widget? suffixWidget;
  final Widget? prefixWidget;
  final VoidCallback? onTap;
  final Color? fillColor;
  final bool? readOnly;
  final bool? isError;
  final int? maxLine;
  final int? minLine;

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 4.h,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Visibility(
          visible: label != null,
          child: Text(
            label ?? '',
            style: GoogleFonts.manrope(fontSize: 11, fontWeight: FontWeight.w500, color: Color(0xFF202020)),
          ),
        ),
        TextFormField(
          readOnly: readOnly ?? true,
          maxLines: maxLine,
          onTap: onTap,
          minLines: minLine,
          controller: (controller != null && text == null) ? controller : TextEditingController(text: text),
          style: GoogleFonts.manrope(fontSize: textSize, fontWeight: textFontWeight, color: textColor),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: GoogleFonts.manrope(fontSize: hintTextSize, fontWeight: hintTextFontWeight, color: hintTextColor),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(enableBorderRadius ?? 12)),
              borderSide: isBorder == true
                  ? BorderSide(color: (isError != null && isError == true) ? Color(0xFFFB3748) : Color(0xFFE8E8E8))
                  : BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(enableBorderRadius ?? 12)),
              borderSide: isBorder == true
                  ? BorderSide(color: (isError != null && isError == true) ? Color(0xFFFB3748) : Color(0xFFE8E8E8))
                  : BorderSide.none,
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(enableBorderRadius ?? 12)),
              borderSide: isBorder == true ? BorderSide(color: Color(0xFFFB3748)) : BorderSide.none,
            ),
            contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 12),
            filled: true,
            fillColor: fillColor,
            suffixIcon: suffixWidget != null ? Padding(padding: EdgeInsets.only(left: 8, right: 12), child: suffixWidget) : null,
            suffixIconConstraints: BoxConstraints(),
            prefixIcon: prefixWidget != null ? Padding(padding: EdgeInsets.only(left: 16, right: 8), child: prefixWidget) : null,
            prefixIconConstraints: BoxConstraints(),
          ),
        ),
        Visibility(
          visible: (isError != null && isError == true && errorText != null),
          child: Text(
            errorText ?? '',
            style: GoogleFonts.manrope(fontSize: errorTextSize, fontWeight: errorTextFontWeight, color: errorTextColor),
          ),
        ),
      ],
    );
  }
}
