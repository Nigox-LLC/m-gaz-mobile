import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:m_gaz/core/utils/style.dart';
import 'colors.dart';

class AppThemes {
  const AppThemes._();

  static ThemeData theme({bool isDark = false}) {
    return ThemeData(
      primaryColor: AppColors.cFF4400,
      scaffoldBackgroundColor: AppColors.white,
      hintColor: Colors.grey[400],
      brightness: Brightness.light,
      fontFamily: GoogleFonts.notoSans().fontFamily,
      dividerColor: Colors.transparent,
      textTheme: GoogleFonts.notoSansTextTheme(
        TextTheme(
          bodyMedium: AppTextStyles.style400.copyWith(
            color: AppColors.black,
            fontSize: 14,
          ),
          bodyLarge: AppTextStyles.style400.copyWith(
            color: AppColors.black,
            fontSize: 12,
          ),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.white,
        elevation: 0,
      ),

      inputDecorationTheme: InputDecorationTheme(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
        filled: true,
        fillColor: Colors.white,
        suffixIconColor: Colors.grey[300],
        hintStyle: const TextStyle(fontSize: 12.0),
        errorStyle: TextStyle(color: Colors.red[500]),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.cFF4400),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[100]!),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.red),
        ),
      ),

      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.white,
        elevation: 0,
        centerTitle: true,
        surfaceTintColor: Colors.transparent,
        iconTheme: IconThemeData(color: AppColors.black),
        titleTextStyle: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 20,
          color: AppColors.cFF4400,
        ),
      ),

      dividerTheme: DividerThemeData(
        space: 1,
        thickness: 1,
        color: Colors.grey[300],
      ),

      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: Colors.lightBlue[100],
        circularTrackColor: Colors.lightBlue[600],
        linearTrackColor: Colors.lightBlue[600],
      ),

      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) {
              return Colors.grey[100];
            }
            return AppColors.white;
          }),
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) {
              return Colors.grey[400];
            }
            return Colors.white;
          }),
          overlayColor: WidgetStateProperty.all(Colors.transparent),
          padding: WidgetStateProperty.all(
            const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          ),
          textStyle: WidgetStateProperty.all(
            const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          shape: WidgetStateProperty.resolveWith((states) {
            final disabled = states.contains(WidgetState.disabled);
            return RoundedRectangleBorder(
              borderRadius: const BorderRadius.all(Radius.circular(8)),
              side: disabled
                  ? BorderSide(width: 1, color: Colors.grey[200]!)
                  : BorderSide.none,
            );
          }),
        ),
      ),

      dialogTheme: DialogThemeData(backgroundColor: AppColors.white), tabBarTheme: TabBarThemeData(indicatorColor: AppColors.cFF4400),
    );
  }
}
