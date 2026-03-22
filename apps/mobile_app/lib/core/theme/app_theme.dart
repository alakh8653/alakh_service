/// Light and dark ThemeData definitions for the AlakhService mobile app.
library app_theme;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_colors.dart';
import 'app_typography.dart';
import 'theme_extensions.dart';

/// Provides Material 3 [ThemeData] for light and dark mode.
abstract final class AppTheme {
  AppTheme._();

  // ── Color schemes ─────────────────────────────────────────────────────────

  static const ColorScheme _lightColorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: AppColors.primary,
    onPrimary: AppColors.onPrimary,
    primaryContainer: Color(0xFFDBEAFE),
    onPrimaryContainer: AppColors.primaryDark,
    secondary: AppColors.secondary,
    onSecondary: AppColors.onSecondary,
    secondaryContainer: Color(0xFFCCFBF1),
    onSecondaryContainer: Color(0xFF0F766E),
    error: AppColors.error,
    onError: AppColors.onError,
    errorContainer: AppColors.errorLight,
    onErrorContainer: Color(0xFF7F1D1D),
    surface: AppColors.surfaceLight,
    onSurface: AppColors.onSurfaceLight,
    surfaceContainerHighest: AppColors.surfaceVariantLight,
    onSurfaceVariant: AppColors.grey600,
    outline: AppColors.grey300,
    outlineVariant: AppColors.grey200,
    shadow: AppColors.black,
    scrim: AppColors.scrim,
    inverseSurface: AppColors.grey800,
    onInverseSurface: AppColors.grey50,
    inversePrimary: AppColors.primaryLight,
  );

  static const ColorScheme _darkColorScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: AppColors.primaryLight,
    onPrimary: AppColors.primaryDark,
    primaryContainer: AppColors.primaryDark,
    onPrimaryContainer: AppColors.primaryLight,
    secondary: AppColors.secondaryLight,
    onSecondary: Color(0xFF003737),
    secondaryContainer: Color(0xFF004F4F),
    onSecondaryContainer: Color(0xFF99F6E4),
    error: Color(0xFFF87171),
    onError: Color(0xFF7F1D1D),
    errorContainer: Color(0xFF991B1B),
    onErrorContainer: Color(0xFFFECACA),
    surface: AppColors.surfaceDark,
    onSurface: AppColors.onSurfaceDark,
    surfaceContainerHighest: AppColors.surfaceVariantDark,
    onSurfaceVariant: AppColors.grey400,
    outline: AppColors.grey600,
    outlineVariant: AppColors.grey700,
    shadow: AppColors.black,
    scrim: AppColors.scrim,
    inverseSurface: AppColors.grey100,
    onInverseSurface: AppColors.grey900,
    inversePrimary: AppColors.primary,
  );

  // ── Theme builders ────────────────────────────────────────────────────────

  /// Light [ThemeData].
  static ThemeData get light => _buildTheme(
        colorScheme: _lightColorScheme,
        statusBarBrightness: Brightness.dark,
        extensions: [AppStatusColors.light, const AppSpacingExtension()],
      );

  /// Dark [ThemeData].
  static ThemeData get dark => _buildTheme(
        colorScheme: _darkColorScheme,
        statusBarBrightness: Brightness.light,
        extensions: [AppStatusColors.dark, const AppSpacingExtension()],
      );

  // ── Private builder ───────────────────────────────────────────────────────

  static ThemeData _buildTheme({
    required ColorScheme colorScheme,
    required Brightness statusBarBrightness,
    required List<ThemeExtension<dynamic>> extensions,
  }) {
    final isLight = colorScheme.brightness == Brightness.light;

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: AppTypography.textTheme.apply(
        bodyColor: colorScheme.onSurface,
        displayColor: colorScheme.onSurface,
      ),
      extensions: extensions,

      // ── AppBar ─────────────────────────────────────────────────────────────
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 1,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        centerTitle: true,
        titleTextStyle: AppTypography.titleLarge.copyWith(
          color: colorScheme.onSurface,
        ),
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: statusBarBrightness,
        ),
      ),

      // ── Card ───────────────────────────────────────────────────────────────
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: isLight ? AppColors.grey200 : AppColors.grey700,
          ),
        ),
        color: colorScheme.surface,
        margin: EdgeInsets.zero,
      ),

      // ── Elevated button ────────────────────────────────────────────────────
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: AppTypography.button,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          minimumSize: const Size(88, 48),
        ),
      ),

      // ── Outlined button ────────────────────────────────────────────────────
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colorScheme.primary,
          side: BorderSide(color: colorScheme.primary),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: AppTypography.button,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          minimumSize: const Size(88, 48),
        ),
      ),

      // ── Text button ────────────────────────────────────────────────────────
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colorScheme.primary,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          textStyle: AppTypography.button,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),

      // ── Input decoration ───────────────────────────────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isLight ? AppColors.grey50 : AppColors.surfaceVariantDark,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: isLight ? AppColors.grey300 : AppColors.grey600,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: isLight ? AppColors.grey300 : AppColors.grey600,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: colorScheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: colorScheme.error, width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: AppTypography.bodyMedium
            .copyWith(color: colorScheme.onSurfaceVariant),
        labelStyle: AppTypography.bodyMedium
            .copyWith(color: colorScheme.onSurfaceVariant),
        errorStyle:
            AppTypography.caption.copyWith(color: colorScheme.error),
      ),

      // ── Bottom navigation bar ──────────────────────────────────────────────
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: colorScheme.surface,
        selectedItemColor: colorScheme.primary,
        unselectedItemColor: colorScheme.onSurfaceVariant,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),

      // ── Divider ────────────────────────────────────────────────────────────
      dividerTheme: DividerThemeData(
        color: isLight ? AppColors.dividerLight : AppColors.dividerDark,
        space: 1,
        thickness: 1,
      ),

      // ── Snack bar ──────────────────────────────────────────────────────────
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        backgroundColor: isLight ? AppColors.grey800 : AppColors.grey200,
        contentTextStyle: AppTypography.bodyMedium.copyWith(
          color: isLight ? AppColors.white : AppColors.grey900,
        ),
      ),

      // ── Dialog ────────────────────────────────────────────────────────────
      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: colorScheme.surface,
        elevation: 3,
      ),

      // ── Bottom sheet ───────────────────────────────────────────────────────
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colorScheme.surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        elevation: 8,
      ),

      // ── Chip ──────────────────────────────────────────────────────────────
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        labelStyle: AppTypography.labelMedium,
        side: BorderSide(
          color: isLight ? AppColors.grey300 : AppColors.grey600,
        ),
      ),
    );
  }
}
