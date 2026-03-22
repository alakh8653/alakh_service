/// Spacing / padding constants.
///
/// A simple 4-pt grid system that keeps layouts consistent.
library app_spacing;

/// Spacing scale based on a 4-pt grid.
///
/// Use `AppSpacing.sm` instead of hard-coding `8.0`, etc.
abstract final class AppSpacing {
  AppSpacing._();

  // ── Base values ───────────────────────────────────────────────────────────

  /// 2 pt
  static const double xxs = 2.0;

  /// 4 pt
  static const double xs = 4.0;

  /// 8 pt
  static const double sm = 8.0;

  /// 12 pt
  static const double md = 12.0;

  /// 16 pt
  static const double lg = 16.0;

  /// 20 pt
  static const double xl = 20.0;

  /// 24 pt
  static const double xxl = 24.0;

  /// 32 pt
  static const double xxxl = 32.0;

  /// 40 pt
  static const double huge = 40.0;

  /// 48 pt
  static const double massive = 48.0;

  /// 64 pt
  static const double gargantuan = 64.0;

  // ── Border radii ──────────────────────────────────────────────────────────

  /// 4 pt – very subtle rounding.
  static const double radiusXs = 4.0;

  /// 8 pt – default card / input rounding.
  static const double radiusSm = 8.0;

  /// 12 pt
  static const double radiusMd = 12.0;

  /// 16 pt
  static const double radiusLg = 16.0;

  /// 24 pt
  static const double radiusXl = 24.0;

  /// 9999 pt – fully round (pill shape / circular).
  static const double radiusFull = 9999.0;

  // ── Icon sizes ────────────────────────────────────────────────────────────

  static const double iconXs = 12.0;
  static const double iconSm = 16.0;
  static const double iconMd = 20.0;
  static const double iconLg = 24.0;
  static const double iconXl = 32.0;
  static const double iconXxl = 40.0;

  // ── Touch targets ─────────────────────────────────────────────────────────

  /// Minimum touch target size recommended by Material / HIG guidelines (48 pt).
  static const double minTouchTarget = 48.0;

  // ── Screen margins ────────────────────────────────────────────────────────

  /// Default horizontal page padding.
  static const double pageHorizontal = lg;

  /// Default vertical page padding.
  static const double pageVertical = lg;

}
