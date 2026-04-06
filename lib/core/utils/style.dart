import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTextStyles {
  AppTextStyles._();

  static final TextStyle _style = GoogleFonts.notoSans().copyWith(fontSize: 14);

  static TextStyle style300 = _style.copyWith(fontWeight: FontWeight.w300);

  static TextStyle style400 = _style.copyWith(fontWeight: FontWeight.w400);

  static TextStyle style500 = _style.copyWith(fontWeight: FontWeight.w500);

  static TextStyle style600 = _style.copyWith(fontWeight: FontWeight.w600);

  static TextStyle style700 = _style.copyWith(fontWeight: FontWeight.w700);
}
