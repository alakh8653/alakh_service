/// Application color palette.
///
/// All colors are defined as `static const` so they are available at
/// compile-time with zero overhead.
library app_colors;

import 'package:flutter/material.dart';

/// Brand and semantic colors for the AlakhService mobile app.
abstract final class AppColors {
  AppColors._();

  // ── Brand ─────────────────────────────────────────────────────────────────

  /// Primary brand color – deep blue.
  static const Color primary = Color(0xFF1A56DB);

  /// Slightly lighter primary for interactive states.
  static const Color primaryLight = Color(0xFF3D71F5);

  /// Dark variant used for pressed / focus states.
  static const Color primaryDark = Color(0xFF1240A8);

  /// Secondary brand color – teal accent.
  static const Color secondary = Color(0xFF0CA5A5);

  /// Light secondary for tinted backgrounds.
  static const Color secondaryLight = Color(0xFF2DBDBD);

  // ── Neutrals ──────────────────────────────────────────────────────────────

  static const Color grey50  = Color(0xFFF9FAFB);
  static const Color grey100 = Color(0xFFF3F4F6);
  static const Color grey200 = Color(0xFFE5E7EB);
  static const Color grey300 = Color(0xFFD1D5DB);
  static const Color grey400 = Color(0xFF9CA3AF);
  static const Color grey500 = Color(0xFF6B7280);
  static const Color grey600 = Color(0xFF4B5563);
  static const Color grey700 = Color(0xFF374151);
  static const Color grey800 = Color(0xFF1F2937);
  static const Color grey900 = Color(0xFF111827);

  // ── Semantic ──────────────────────────────────────────────────────────────

  /// Success / positive feedback.
  static const Color success = Color(0xFF10B981);
  static const Color successLight = Color(0xFFD1FAE5);

  /// Warning / caution.
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFEF3C7);

  /// Error / destructive action.
  static const Color error = Color(0xFFEF4444);
  static const Color errorLight = Color(0xFFFEE2E2);

  /// Informational.
  static const Color info = Color(0xFF3B82F6);
  static const Color infoLight = Color(0xFFDBEAFE);

  // ── Surfaces (light) ──────────────────────────────────────────────────────

  static const Color backgroundLight = Color(0xFFF9FAFB);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceVariantLight = Color(0xFFF3F4F6);

  // ── Surfaces (dark) ───────────────────────────────────────────────────────

  static const Color backgroundDark = Color(0xFF0F172A);
  static const Color surfaceDark = Color(0xFF1E293B);
  static const Color surfaceVariantDark = Color(0xFF334155);

  // ── On-colors ─────────────────────────────────────────────────────────────

  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color onBackgroundLight = Color(0xFF111827);
  static const Color onBackgroundDark = Color(0xFFF1F5F9);
  static const Color onSurfaceLight = Color(0xFF1F2937);
  static const Color onSurfaceDark = Color(0xFFE2E8F0);

  // ── Misc ─────────────────────────────────────────────────────────────────

  static const Color transparent = Colors.transparent;
  static const Color white = Colors.white;
  static const Color black = Colors.black;

  /// Scrim / overlay color used for bottom sheets and dialogs.
  static const Color scrim = Color(0x80000000);

  /// Divider / separator line color (light mode).
  static const Color dividerLight = Color(0xFFE5E7EB);

  /// Divider / separator line color (dark mode).
  static const Color dividerDark = Color(0xFF334155);
}
