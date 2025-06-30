// lib/core/theme/app_theme.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: AppColors.primary,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        tertiary: AppColors.tertiary,
        error: AppColors.danger,
        surface: Colors.white,
      ),
      scaffoldBackgroundColor: AppColors.gray10,
      fontFamily: 'Poppins',
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: AppDimensions.heading1,
          fontWeight: FontWeight.bold,
          color: AppColors.gray90,
        ),
        displayMedium: TextStyle(
          fontSize: AppDimensions.heading2,
          fontWeight: FontWeight.bold,
          color: AppColors.gray90,
        ),
        displaySmall: TextStyle(
          fontSize: AppDimensions.heading3,
          fontWeight: FontWeight.w600,
          color: AppColors.gray90,
        ),
        headlineMedium: TextStyle(
          fontSize: AppDimensions.heading4,
          fontWeight: FontWeight.w600,
          color: AppColors.gray90,
        ),
        bodyLarge: TextStyle(
          fontSize: AppDimensions.paragraph,
          fontWeight: FontWeight.normal,
          color: AppColors.gray80,
        ),
        bodyMedium: TextStyle(
          fontSize: AppDimensions.small,
          fontWeight: FontWeight.normal,
          color: AppColors.gray80,
        ),
        labelLarge: TextStyle(
          fontSize: AppDimensions.paragraph,
          fontWeight: FontWeight.w500,
          color: AppColors.gray90,
        ),
        bodySmall: TextStyle(
          fontSize: AppDimensions.caption,
          fontWeight: FontWeight.normal,
          color: AppColors.gray70,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(
            vertical: AppDimensions.spacing4,
            horizontal: AppDimensions.spacing6,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          ),
          elevation: 1,
          textStyle: const TextStyle(
            fontSize: AppDimensions.paragraph,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary),
          padding: const EdgeInsets.symmetric(
            vertical: AppDimensions.spacing4,
            horizontal: AppDimensions.spacing6,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          ),
          textStyle: const TextStyle(
            fontSize: AppDimensions.paragraph,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: const TextStyle(
            fontSize: AppDimensions.paragraph,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          vertical: AppDimensions.spacing3,
          horizontal: AppDimensions.spacing4,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          borderSide: const BorderSide(color: AppColors.gray40),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          borderSide: const BorderSide(color: AppColors.gray40),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          borderSide: const BorderSide(color: AppColors.danger),
        ),
        hintStyle: const TextStyle(
          fontSize: AppDimensions.paragraph,
          color: AppColors.gray60,
        ),
        labelStyle: const TextStyle(
          fontSize: AppDimensions.small,
          fontWeight: FontWeight.w500,
          color: AppColors.gray70,
        ),
      ),
      cardTheme: const CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(AppDimensions.radiusMedium)),
        ),
        color: Colors.white,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      primaryColor: AppColors.primary,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        tertiary: AppColors.tertiary,
        error: AppColors.danger,
        surface: AppColors.gray80,
      ),
      scaffoldBackgroundColor: AppColors.gray90,
      fontFamily: 'Poppins',
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: AppDimensions.heading1,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        displayMedium: TextStyle(
          fontSize: AppDimensions.heading2,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        displaySmall: TextStyle(
          fontSize: AppDimensions.heading3,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        headlineMedium: TextStyle(
          fontSize: AppDimensions.heading4,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        bodyLarge: TextStyle(
          fontSize: AppDimensions.paragraph,
          fontWeight: FontWeight.normal,
          color: AppColors.gray20,
        ),
        bodyMedium: TextStyle(
          fontSize: AppDimensions.small,
          fontWeight: FontWeight.normal,
          color: AppColors.gray20,
        ),
        labelLarge: TextStyle(
          fontSize: AppDimensions.paragraph,
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),
        bodySmall: TextStyle(
          fontSize: AppDimensions.caption,
          fontWeight: FontWeight.normal,
          color: AppColors.gray40,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(
            vertical: AppDimensions.spacing4,
            horizontal: AppDimensions.spacing6,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          ),
          elevation: 1,
          textStyle: const TextStyle(
            fontSize: AppDimensions.paragraph,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary),
          padding: const EdgeInsets.symmetric(
            vertical: AppDimensions.spacing4,
            horizontal: AppDimensions.spacing6,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          ),
          textStyle: const TextStyle(
            fontSize: AppDimensions.paragraph,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: const TextStyle(
            fontSize: AppDimensions.paragraph,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.gray80,
        contentPadding: const EdgeInsets.symmetric(
          vertical: AppDimensions.spacing3,
          horizontal: AppDimensions.spacing4,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          borderSide: const BorderSide(color: AppColors.gray60),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          borderSide: const BorderSide(color: AppColors.gray60),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          borderSide: const BorderSide(color: AppColors.danger),
        ),
        hintStyle: const TextStyle(
          fontSize: AppDimensions.paragraph,
          color: AppColors.gray50,
        ),
        labelStyle: const TextStyle(
          fontSize: AppDimensions.small,
          fontWeight: FontWeight.w500,
          color: AppColors.gray40,
        ),
      ),
      cardTheme: const CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(AppDimensions.radiusMedium)),
        ),
        color: AppColors.gray80,
      ),
    );
  }
}