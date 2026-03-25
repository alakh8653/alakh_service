import 'package:flutter/material.dart';

import 'ui_kit_border_radius.dart';
import 'ui_kit_colors.dart';
import 'ui_kit_typography.dart';

/// Provides pre-built [ThemeData] for light and dark modes using UI kit constants.
class UiKitTheme {
  const UiKitTheme._();

  /// Returns the light [ThemeData]. Optionally supply a [fontFamily].
  static ThemeData lightTheme({String? fontFamily}) {
    final textTheme = UiKitTypography.textTheme(fontFamily: fontFamily);
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: UiKitColors.primary,
        onPrimary: UiKitColors.white,
        primaryContainer: UiKitColors.primaryLight,
        onPrimaryContainer: UiKitColors.primaryDark,
        secondary: UiKitColors.secondary,
        onSecondary: UiKitColors.white,
        secondaryContainer: Color(0xFFB2F2E0),
        onSecondaryContainer: UiKitColors.secondaryDark,
        error: UiKitColors.error,
        onError: UiKitColors.white,
        surface: UiKitColors.surfaceLight,
        onSurface: UiKitColors.textPrimary,
        surfaceContainerHighest: UiKitColors.grey100,
        outline: UiKitColors.grey300,
      ),
      scaffoldBackgroundColor: UiKitColors.backgroundLight,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: UiKitColors.surfaceLight,
        foregroundColor: UiKitColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 1,
        titleTextStyle: textTheme.titleLarge,
        centerTitle: false,
      ),
      cardTheme: const CardThemeData(
        color: UiKitColors.surfaceLight,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: UiKitBorderRadius.lgAll,
          side: BorderSide(color: UiKitColors.grey200),
        ),
        margin: EdgeInsets.zero,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: UiKitColors.primary,
          foregroundColor: UiKitColors.white,
          elevation: 0,
          shape: const RoundedRectangleBorder(
            borderRadius: UiKitBorderRadius.smAll,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: textTheme.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: UiKitColors.primary,
          side: const BorderSide(color: UiKitColors.primary, width: 1.5),
          shape: const RoundedRectangleBorder(
            borderRadius: UiKitBorderRadius.smAll,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: textTheme.labelLarge,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: UiKitColors.primary,
          shape: const RoundedRectangleBorder(
            borderRadius: UiKitBorderRadius.smAll,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          textStyle: textTheme.labelLarge,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: UiKitColors.grey50,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: UiKitBorderRadius.smAll,
          borderSide: const BorderSide(color: UiKitColors.grey300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: UiKitBorderRadius.smAll,
          borderSide: const BorderSide(color: UiKitColors.grey300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: UiKitBorderRadius.smAll,
          borderSide: const BorderSide(color: UiKitColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: UiKitBorderRadius.smAll,
          borderSide: const BorderSide(color: UiKitColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: UiKitBorderRadius.smAll,
          borderSide: const BorderSide(color: UiKitColors.error, width: 1.5),
        ),
        labelStyle: textTheme.bodyMedium?.copyWith(color: UiKitColors.textSecondary),
        hintStyle: textTheme.bodyMedium?.copyWith(color: UiKitColors.textDisabled),
        errorStyle: textTheme.bodySmall?.copyWith(color: UiKitColors.error),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: UiKitColors.grey100,
        labelStyle: textTheme.labelMedium,
        shape: const RoundedRectangleBorder(
          borderRadius: UiKitBorderRadius.fullAll,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      ),
      dividerTheme: const DividerThemeData(
        color: UiKitColors.grey200,
        thickness: 1,
        space: 1,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: const RoundedRectangleBorder(
          borderRadius: UiKitBorderRadius.smAll,
        ),
        contentTextStyle: textTheme.bodyMedium?.copyWith(color: UiKitColors.white),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: UiKitColors.primary,
        linearTrackColor: UiKitColors.grey200,
      ),
    );
  }

  /// Returns the dark [ThemeData]. Optionally supply a [fontFamily].
  static ThemeData darkTheme({String? fontFamily}) {
    final textTheme = UiKitTypography.textTheme(fontFamily: fontFamily).apply(
      bodyColor: UiKitColors.white,
      displayColor: UiKitColors.white,
    );
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: UiKitColors.primaryLight,
        onPrimary: UiKitColors.primaryDark,
        primaryContainer: UiKitColors.primaryDark,
        onPrimaryContainer: UiKitColors.primaryLight,
        secondary: UiKitColors.secondary,
        onSecondary: UiKitColors.black,
        secondaryContainer: UiKitColors.secondaryDark,
        onSecondaryContainer: UiKitColors.secondary,
        error: UiKitColors.error,
        onError: UiKitColors.white,
        surface: UiKitColors.surfaceDark,
        onSurface: UiKitColors.white,
        surfaceContainerHighest: Color(0xFF1E2A3D),
        outline: UiKitColors.grey600,
      ),
      scaffoldBackgroundColor: UiKitColors.backgroundDark,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: UiKitColors.surfaceDark,
        foregroundColor: UiKitColors.white,
        elevation: 0,
        scrolledUnderElevation: 1,
        titleTextStyle: textTheme.titleLarge?.copyWith(color: UiKitColors.white),
        centerTitle: false,
      ),
      cardTheme: const CardThemeData(
        color: UiKitColors.surfaceDark,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: UiKitBorderRadius.lgAll,
          side: BorderSide(color: Color(0xFF1E2A3D)),
        ),
        margin: EdgeInsets.zero,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: UiKitColors.primaryLight,
          foregroundColor: UiKitColors.primaryDark,
          elevation: 0,
          shape: const RoundedRectangleBorder(
            borderRadius: UiKitBorderRadius.smAll,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: textTheme.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: UiKitColors.primaryLight,
          side: const BorderSide(color: UiKitColors.primaryLight, width: 1.5),
          shape: const RoundedRectangleBorder(
            borderRadius: UiKitBorderRadius.smAll,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: textTheme.labelLarge,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: UiKitColors.primaryLight,
          shape: const RoundedRectangleBorder(
            borderRadius: UiKitBorderRadius.smAll,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          textStyle: textTheme.labelLarge,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF1E2A3D),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: UiKitBorderRadius.smAll,
          borderSide: const BorderSide(color: UiKitColors.grey600),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: UiKitBorderRadius.smAll,
          borderSide: const BorderSide(color: UiKitColors.grey600),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: UiKitBorderRadius.smAll,
          borderSide: const BorderSide(color: UiKitColors.primaryLight, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: UiKitBorderRadius.smAll,
          borderSide: const BorderSide(color: UiKitColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: UiKitBorderRadius.smAll,
          borderSide: const BorderSide(color: UiKitColors.error, width: 1.5),
        ),
        labelStyle: textTheme.bodyMedium?.copyWith(color: UiKitColors.grey400),
        hintStyle: textTheme.bodyMedium?.copyWith(color: UiKitColors.grey600),
        errorStyle: textTheme.bodySmall?.copyWith(color: UiKitColors.error),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: UiKitColors.grey800,
        labelStyle: textTheme.labelMedium?.copyWith(color: UiKitColors.white),
        shape: const RoundedRectangleBorder(
          borderRadius: UiKitBorderRadius.fullAll,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      ),
      dividerTheme: const DividerThemeData(
        color: UiKitColors.grey700,
        thickness: 1,
        space: 1,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: const RoundedRectangleBorder(
          borderRadius: UiKitBorderRadius.smAll,
        ),
        contentTextStyle: textTheme.bodyMedium?.copyWith(color: UiKitColors.white),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: UiKitColors.primaryLight,
        linearTrackColor: UiKitColors.grey700,
      ),
    );
  }
}
