/// Shadow / elevation definitions.
///
/// Provides consistent [BoxShadow] presets that match the design system.
library app_shadows;

import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Pre-defined [BoxShadow] lists used throughout the app.
abstract final class AppShadows {
  AppShadows._();

  // ── Elevation levels ──────────────────────────────────────────────────────

  /// No shadow (flat).
  static const List<BoxShadow> none = [];

  /// Very subtle shadow for cards on a white background.
  static const List<BoxShadow> xs = [
    BoxShadow(
      color: Color(0x0A000000),
      blurRadius: 4,
      offset: Offset(0, 1),
    ),
  ];

  /// Small shadow – default card elevation.
  static const List<BoxShadow> sm = [
    BoxShadow(
      color: Color(0x14000000),
      blurRadius: 8,
      offset: Offset(0, 2),
    ),
  ];

  /// Medium shadow – dialogs, bottom sheets.
  static const List<BoxShadow> md = [
    BoxShadow(
      color: Color(0x1A000000),
      blurRadius: 16,
      offset: Offset(0, 4),
    ),
  ];

  /// Large shadow – floating action buttons, popovers.
  static const List<BoxShadow> lg = [
    BoxShadow(
      color: Color(0x26000000),
      blurRadius: 24,
      offset: Offset(0, 8),
    ),
  ];

  /// Extra-large shadow – modals, overlays.
  static const List<BoxShadow> xl = [
    BoxShadow(
      color: Color(0x33000000),
      blurRadius: 40,
      offset: Offset(0, 16),
    ),
  ];

  // ── Colored shadows ───────────────────────────────────────────────────────

  /// Primary-colored glow for primary action buttons.
  static final List<BoxShadow> primaryGlow = [
    BoxShadow(
      color: AppColors.primary.withOpacity(0.35),
      blurRadius: 16,
      offset: const Offset(0, 6),
    ),
  ];

  /// Success-colored glow.
  static final List<BoxShadow> successGlow = [
    BoxShadow(
      color: AppColors.success.withOpacity(0.35),
      blurRadius: 16,
      offset: const Offset(0, 6),
    ),
  ];

  /// Error-colored glow.
  static final List<BoxShadow> errorGlow = [
    BoxShadow(
      color: AppColors.error.withOpacity(0.35),
      blurRadius: 16,
      offset: const Offset(0, 6),
    ),
  ];
}
