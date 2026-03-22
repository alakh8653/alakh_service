/// UI-related constants: border radii, icon sizes, spacing, and line limits.
library;

/// Centralised UI constants to ensure visual consistency across the app.
abstract final class UiConstants {
  // ---------------------------------------------------------------------------
  // Border Radii
  // ---------------------------------------------------------------------------

  /// No rounding (square corners).
  static const double radiusNone = 0.0;

  /// Extra-small radius — used for chips and small badges.
  static const double radiusXs = 4.0;

  /// Small radius — used for input fields, cards.
  static const double radiusSm = 8.0;

  /// Medium radius — used for modal bottom sheets, dialogs.
  static const double radiusMd = 12.0;

  /// Large radius — used for bottom navigation bar, full-width cards.
  static const double radiusLg = 16.0;

  /// Extra-large radius — used for hero cards.
  static const double radiusXl = 24.0;

  /// Full circular radius (use with square containers for circles).
  static const double radiusFull = 999.0;

  // ---------------------------------------------------------------------------
  // Icon Sizes
  // ---------------------------------------------------------------------------

  /// Extra-small icon (e.g. badge icon).
  static const double iconXs = 12.0;

  /// Small icon (e.g. trailing icon in list tiles).
  static const double iconSm = 16.0;

  /// Default / medium icon size.
  static const double iconMd = 24.0;

  /// Large icon (e.g. empty-state icon).
  static const double iconLg = 32.0;

  /// Extra-large icon (e.g. feature illustrations).
  static const double iconXl = 48.0;

  /// 2× extra-large icon.
  static const double icon2Xl = 64.0;

  // ---------------------------------------------------------------------------
  // Avatar Sizes
  // ---------------------------------------------------------------------------

  /// Tiny avatar used in list tiles or chat bubbles.
  static const double avatarXs = 24.0;

  /// Small avatar used in compact views.
  static const double avatarSm = 36.0;

  /// Default avatar size.
  static const double avatarMd = 48.0;

  /// Large avatar used on profile screens.
  static const double avatarLg = 72.0;

  /// Extra-large avatar used on the full profile header.
  static const double avatarXl = 96.0;

  // ---------------------------------------------------------------------------
  // Spacing / Padding
  // ---------------------------------------------------------------------------

  /// 4 dp
  static const double spacingXs = 4.0;

  /// 8 dp
  static const double spacingSm = 8.0;

  /// 12 dp
  static const double spacingMd = 12.0;

  /// 16 dp
  static const double spacingLg = 16.0;

  /// 20 dp
  static const double spacingXl = 20.0;

  /// 24 dp
  static const double spacing2Xl = 24.0;

  /// 32 dp
  static const double spacing3Xl = 32.0;

  /// 48 dp
  static const double spacing4Xl = 48.0;

  // ---------------------------------------------------------------------------
  // Text / Max Lines
  // ---------------------------------------------------------------------------

  /// Single-line clipping (e.g. list-tile titles).
  static const int maxLinesSingle = 1;

  /// Two-line text (e.g. card subtitles).
  static const int maxLinesDouble = 2;

  /// Three-line description text.
  static const int maxLinesTriple = 3;

  // ---------------------------------------------------------------------------
  // Elevation / Shadow
  // ---------------------------------------------------------------------------

  /// No elevation.
  static const double elevationNone = 0.0;

  /// Subtle card elevation.
  static const double elevationCard = 2.0;

  /// Modal/dialog elevation.
  static const double elevationModal = 8.0;

  /// Floating action button elevation.
  static const double elevationFab = 6.0;

  // ---------------------------------------------------------------------------
  // Bottom Navigation Bar
  // ---------------------------------------------------------------------------

  /// Height of the custom bottom navigation bar.
  static const double bottomNavHeight = 64.0;

  /// Padding above the bottom-nav icons.
  static const double bottomNavTopPadding = 8.0;

  // ---------------------------------------------------------------------------
  // App Bar
  // ---------------------------------------------------------------------------

  /// Standard app-bar height (Material default is 56 dp).
  static const double appBarHeight = 56.0;

  // ---------------------------------------------------------------------------
  // Button Sizes
  // ---------------------------------------------------------------------------

  /// Minimum touch target height for interactive elements (Material guideline).
  static const double minTouchTarget = 48.0;

  /// Default button height.
  static const double buttonHeight = 52.0;

  /// Small button height.
  static const double buttonHeightSm = 36.0;

  // ---------------------------------------------------------------------------
  // Input Fields
  // ---------------------------------------------------------------------------

  /// Height of a standard text-input field.
  static const double inputHeight = 56.0;

  // ---------------------------------------------------------------------------
  // Shimmer / Skeleton
  // ---------------------------------------------------------------------------

  /// Width of shimmer blocks used in skeleton loaders.
  static const double shimmerBaseOpacity = 0.3;

  /// Highlighted opacity in the shimmer sweep.
  static const double shimmerHighlightOpacity = 0.6;
}
