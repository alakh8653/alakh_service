import 'package:flutter/material.dart';

import 'ui_kit_colors.dart';

/// Typography scale following Material Design 3 naming conventions.
abstract class UiKitTypography {
  /// Returns a full [TextTheme] using the given [fontFamily].
  static TextTheme textTheme({String? fontFamily}) {
    return TextTheme(
      displayLarge: displayLarge.copyWith(fontFamily: fontFamily),
      displayMedium: displayMedium.copyWith(fontFamily: fontFamily),
      displaySmall: displaySmall.copyWith(fontFamily: fontFamily),
      headlineLarge: headlineLarge.copyWith(fontFamily: fontFamily),
      headlineMedium: headlineMedium.copyWith(fontFamily: fontFamily),
      headlineSmall: headlineSmall.copyWith(fontFamily: fontFamily),
      titleLarge: titleLarge.copyWith(fontFamily: fontFamily),
      titleMedium: titleMedium.copyWith(fontFamily: fontFamily),
      titleSmall: titleSmall.copyWith(fontFamily: fontFamily),
      bodyLarge: bodyLarge.copyWith(fontFamily: fontFamily),
      bodyMedium: bodyMedium.copyWith(fontFamily: fontFamily),
      bodySmall: bodySmall.copyWith(fontFamily: fontFamily),
      labelLarge: labelLarge.copyWith(fontFamily: fontFamily),
      labelMedium: labelMedium.copyWith(fontFamily: fontFamily),
      labelSmall: labelSmall.copyWith(fontFamily: fontFamily),
    );
  }

  static const TextStyle displayLarge = TextStyle(
    fontSize: 57,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.25,
    height: 1.12,
    color: UiKitColors.textPrimary,
  );

  static const TextStyle displayMedium = TextStyle(
    fontSize: 45,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    height: 1.16,
    color: UiKitColors.textPrimary,
  );

  static const TextStyle displaySmall = TextStyle(
    fontSize: 36,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    height: 1.22,
    color: UiKitColors.textPrimary,
  );

  static const TextStyle headlineLarge = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    letterSpacing: 0,
    height: 1.25,
    color: UiKitColors.textPrimary,
  );

  static const TextStyle headlineMedium = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.29,
    color: UiKitColors.textPrimary,
  );

  static const TextStyle headlineSmall = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.33,
    color: UiKitColors.textPrimary,
  );

  static const TextStyle titleLarge = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.27,
    color: UiKitColors.textPrimary,
  );

  static const TextStyle titleMedium = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.15,
    height: 1.5,
    color: UiKitColors.textPrimary,
  );

  static const TextStyle titleSmall = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
    height: 1.43,
    color: UiKitColors.textPrimary,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.5,
    height: 1.5,
    color: UiKitColors.textPrimary,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.25,
    height: 1.43,
    color: UiKitColors.textPrimary,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.4,
    height: 1.33,
    color: UiKitColors.textSecondary,
  );

  static const TextStyle labelLarge = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
    height: 1.43,
    color: UiKitColors.textPrimary,
  );

  static const TextStyle labelMedium = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    height: 1.33,
    color: UiKitColors.textPrimary,
  );

  static const TextStyle labelSmall = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    height: 1.45,
    color: UiKitColors.textSecondary,
  );
}
