import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_text_styles.dart';

/// Light and dark [ThemeData] for the AlakhService design system.
class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          brightness: Brightness.light,
          surface: AppColors.surfaceLight,
          error: AppColors.error,
        ),
        scaffoldBackgroundColor: AppColors.backgroundLight,
        textTheme: _textTheme(AppColors.textPrimary),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          filled: true,
          fillColor: AppColors.surfaceLight,
        ),
        dividerColor: AppColors.divider,
      );

  static ThemeData get darkTheme => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          brightness: Brightness.dark,
          surface: AppColors.surfaceDark,
          error: AppColors.error,
        ),
        scaffoldBackgroundColor: AppColors.backgroundDark,
        textTheme: _textTheme(AppColors.textPrimaryDark),
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.surfaceDark,
          foregroundColor: AppColors.textPrimaryDark,
          elevation: 0,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryLight,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          filled: true,
          fillColor: AppColors.surfaceDark,
        ),
        dividerColor: AppColors.dividerDark,
      );

  static TextTheme _textTheme(Color defaultColor) => TextTheme(
        displayLarge: AppTextStyles.displayLarge.copyWith(color: defaultColor),
        displayMedium: AppTextStyles.displayMedium.copyWith(color: defaultColor),
        headlineLarge: AppTextStyles.headlineLarge.copyWith(color: defaultColor),
        headlineMedium: AppTextStyles.headlineMedium.copyWith(color: defaultColor),
        headlineSmall: AppTextStyles.headlineSmall.copyWith(color: defaultColor),
        titleLarge: AppTextStyles.titleLarge.copyWith(color: defaultColor),
        titleMedium: AppTextStyles.titleMedium.copyWith(color: defaultColor),
        titleSmall: AppTextStyles.titleSmall.copyWith(color: defaultColor),
        bodyLarge: AppTextStyles.bodyLarge.copyWith(color: defaultColor),
        bodyMedium: AppTextStyles.bodyMedium.copyWith(color: defaultColor),
        bodySmall: AppTextStyles.bodySmall,
        labelLarge: AppTextStyles.labelLarge,
        labelSmall: AppTextStyles.labelSmall,
      );
}
