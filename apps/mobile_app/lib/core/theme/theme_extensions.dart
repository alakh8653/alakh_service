/// Custom [ThemeExtension] classes that extend Material ThemeData.
///
/// Extensions let widgets access custom design tokens through the standard
/// `Theme.of(context)` API without polluting the core [ThemeData].
library theme_extensions;

import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_spacing.dart';

// ── Status colors extension ───────────────────────────────────────────────────

/// Provides semantic status colors (success, warning, info) via ThemeData.
@immutable
class AppStatusColors extends ThemeExtension<AppStatusColors> {
  const AppStatusColors({
    required this.success,
    required this.successContainer,
    required this.onSuccess,
    required this.warning,
    required this.warningContainer,
    required this.onWarning,
    required this.info,
    required this.infoContainer,
    required this.onInfo,
  });

  final Color success;
  final Color successContainer;
  final Color onSuccess;
  final Color warning;
  final Color warningContainer;
  final Color onWarning;
  final Color info;
  final Color infoContainer;
  final Color onInfo;

  /// Light-mode defaults.
  static const light = AppStatusColors(
    success: AppColors.success,
    successContainer: AppColors.successLight,
    onSuccess: AppColors.white,
    warning: AppColors.warning,
    warningContainer: AppColors.warningLight,
    onWarning: AppColors.white,
    info: AppColors.info,
    infoContainer: AppColors.infoLight,
    onInfo: AppColors.white,
  );

  /// Dark-mode defaults (same hues, containers are darker).
  static const dark = AppStatusColors(
    success: Color(0xFF34D399),
    successContainer: Color(0xFF064E3B),
    onSuccess: Color(0xFF022C22),
    warning: Color(0xFFFBBF24),
    warningContainer: Color(0xFF78350F),
    onWarning: Color(0xFF451A03),
    info: Color(0xFF60A5FA),
    infoContainer: Color(0xFF1E3A5F),
    onInfo: Color(0xFF0C1A2E),
  );

  @override
  AppStatusColors copyWith({
    Color? success,
    Color? successContainer,
    Color? onSuccess,
    Color? warning,
    Color? warningContainer,
    Color? onWarning,
    Color? info,
    Color? infoContainer,
    Color? onInfo,
  }) {
    return AppStatusColors(
      success: success ?? this.success,
      successContainer: successContainer ?? this.successContainer,
      onSuccess: onSuccess ?? this.onSuccess,
      warning: warning ?? this.warning,
      warningContainer: warningContainer ?? this.warningContainer,
      onWarning: onWarning ?? this.onWarning,
      info: info ?? this.info,
      infoContainer: infoContainer ?? this.infoContainer,
      onInfo: onInfo ?? this.onInfo,
    );
  }

  @override
  AppStatusColors lerp(AppStatusColors? other, double t) {
    if (other == null) return this;
    return AppStatusColors(
      success: Color.lerp(success, other.success, t)!,
      successContainer: Color.lerp(successContainer, other.successContainer, t)!,
      onSuccess: Color.lerp(onSuccess, other.onSuccess, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      warningContainer: Color.lerp(warningContainer, other.warningContainer, t)!,
      onWarning: Color.lerp(onWarning, other.onWarning, t)!,
      info: Color.lerp(info, other.info, t)!,
      infoContainer: Color.lerp(infoContainer, other.infoContainer, t)!,
      onInfo: Color.lerp(onInfo, other.onInfo, t)!,
    );
  }
}

// ── Spacing extension ─────────────────────────────────────────────────────────

/// Provides typed spacing constants through the theme.
@immutable
class AppSpacingExtension extends ThemeExtension<AppSpacingExtension> {
  const AppSpacingExtension({
    this.xs = AppSpacing.xs,
    this.sm = AppSpacing.sm,
    this.md = AppSpacing.md,
    this.lg = AppSpacing.lg,
    this.xl = AppSpacing.xl,
    this.xxl = AppSpacing.xxl,
    this.xxxl = AppSpacing.xxxl,
  });

  final double xs;
  final double sm;
  final double md;
  final double lg;
  final double xl;
  final double xxl;
  final double xxxl;

  static const defaultSpacing = AppSpacingExtension();

  @override
  AppSpacingExtension copyWith({
    double? xs,
    double? sm,
    double? md,
    double? lg,
    double? xl,
    double? xxl,
    double? xxxl,
  }) {
    return AppSpacingExtension(
      xs: xs ?? this.xs,
      sm: sm ?? this.sm,
      md: md ?? this.md,
      lg: lg ?? this.lg,
      xl: xl ?? this.xl,
      xxl: xxl ?? this.xxl,
      xxxl: xxxl ?? this.xxxl,
    );
  }

  @override
  AppSpacingExtension lerp(AppSpacingExtension? other, double t) {
    if (other == null) return this;
    return AppSpacingExtension(
      xs: _lerpDouble(xs, other.xs, t),
      sm: _lerpDouble(sm, other.sm, t),
      md: _lerpDouble(md, other.md, t),
      lg: _lerpDouble(lg, other.lg, t),
      xl: _lerpDouble(xl, other.xl, t),
      xxl: _lerpDouble(xxl, other.xxl, t),
      xxxl: _lerpDouble(xxxl, other.xxxl, t),
    );
  }

  static double _lerpDouble(double a, double b, double t) =>
      a + (b - a) * t;
}

// ── Convenience extension on BuildContext ─────────────────────────────────────

/// Convenience accessors so widgets can write
/// `context.statusColors.success` instead of
/// `Theme.of(context).extension<AppStatusColors>()!.success`.
extension ThemeExtensionX on BuildContext {
  /// Access [AppStatusColors] from the current theme.
  AppStatusColors get statusColors =>
      Theme.of(this).extension<AppStatusColors>() ?? AppStatusColors.light;

  /// Access [AppSpacingExtension] from the current theme.
  AppSpacingExtension get spacing =>
      Theme.of(this).extension<AppSpacingExtension>() ??
      const AppSpacingExtension();
}
