/// Asset path constants for images, icons, animations, and fonts.
library;

/// Provides typed, compile-time-safe paths to every asset bundled with the app.
///
/// Assets are organised under `apps/mobile_app/assets/` and referenced here
/// relative to that root so Flutter's asset system can resolve them correctly.
abstract final class AssetPaths {
  // ---------------------------------------------------------------------------
  // Root directories (do not use directly)
  // ---------------------------------------------------------------------------
  static const String _images = 'assets/images';
  static const String _icons = 'assets/icons';
  static const String _animations = 'assets/animations';
  static const String _fonts = 'assets/fonts';

  // ---------------------------------------------------------------------------
  // Images — General
  // ---------------------------------------------------------------------------

  /// Application logo (full colour, used on splash / onboarding).
  static const String logo = '$_images/logo.png';

  /// Application logo in white (used on dark backgrounds).
  static const String logoWhite = '$_images/logo_white.png';

  /// Application icon (used in about screens, notifications).
  static const String appIcon = '$_images/app_icon.png';

  /// Placeholder image shown while network images load.
  static const String imagePlaceholder = '$_images/image_placeholder.png';

  /// Generic avatar placeholder used when no user photo is available.
  static const String avatarPlaceholder = '$_images/avatar_placeholder.png';

  /// Map placeholder displayed when location services are unavailable.
  static const String mapPlaceholder = '$_images/map_placeholder.png';

  // ---------------------------------------------------------------------------
  // Images — Onboarding
  // ---------------------------------------------------------------------------

  /// Illustration for onboarding screen 1.
  static const String onboarding1 = '$_images/onboarding/onboarding_1.png';

  /// Illustration for onboarding screen 2.
  static const String onboarding2 = '$_images/onboarding/onboarding_2.png';

  /// Illustration for onboarding screen 3.
  static const String onboarding3 = '$_images/onboarding/onboarding_3.png';

  // ---------------------------------------------------------------------------
  // Images — Empty States
  // ---------------------------------------------------------------------------

  /// Illustration shown when a search returns no results.
  static const String emptySearch = '$_images/empty/empty_search.png';

  /// Illustration shown when there are no bookings.
  static const String emptyBookings = '$_images/empty/empty_bookings.png';

  /// Illustration shown when the notifications list is empty.
  static const String emptyNotifications =
      '$_images/empty/empty_notifications.png';

  /// Illustration shown when the cart is empty.
  static const String emptyCart = '$_images/empty/empty_cart.png';

  // ---------------------------------------------------------------------------
  // Images — Error States
  // ---------------------------------------------------------------------------

  /// Illustration for generic errors.
  static const String errorGeneral = '$_images/error/error_general.png';

  /// Illustration for network / connectivity errors.
  static const String errorNetwork = '$_images/error/error_network.png';

  /// Illustration for 404 / not-found errors.
  static const String errorNotFound = '$_images/error/error_not_found.png';

  // ---------------------------------------------------------------------------
  // Icons (SVG / PNG)
  // ---------------------------------------------------------------------------

  /// Home tab icon.
  static const String iconHome = '$_icons/ic_home.svg';

  /// Bookings tab icon.
  static const String iconBookings = '$_icons/ic_bookings.svg';

  /// Notifications tab icon.
  static const String iconNotifications = '$_icons/ic_notifications.svg';

  /// Profile tab icon.
  static const String iconProfile = '$_icons/ic_profile.svg';

  /// Search icon.
  static const String iconSearch = '$_icons/ic_search.svg';

  /// Filter / sort icon.
  static const String iconFilter = '$_icons/ic_filter.svg';

  /// Location / GPS pin icon.
  static const String iconLocation = '$_icons/ic_location.svg';

  /// Star icon used in ratings.
  static const String iconStar = '$_icons/ic_star.svg';

  /// Calendar icon.
  static const String iconCalendar = '$_icons/ic_calendar.svg';

  /// Camera icon.
  static const String iconCamera = '$_icons/ic_camera.svg';

  /// Gallery icon.
  static const String iconGallery = '$_icons/ic_gallery.svg';

  /// Share icon.
  static const String iconShare = '$_icons/ic_share.svg';

  /// Copy icon (clipboard).
  static const String iconCopy = '$_icons/ic_copy.svg';

  // ---------------------------------------------------------------------------
  // Animations (Lottie JSON)
  // ---------------------------------------------------------------------------

  /// Lottie animation shown on the splash screen.
  static const String animSplash = '$_animations/anim_splash.json';

  /// Lottie success / check-mark animation.
  static const String animSuccess = '$_animations/anim_success.json';

  /// Lottie error / cross animation.
  static const String animError = '$_animations/anim_error.json';

  /// Lottie full-screen loading animation.
  static const String animLoading = '$_animations/anim_loading.json';

  /// Lottie empty-state animation (generic).
  static const String animEmpty = '$_animations/anim_empty.json';

  /// Lottie animation indicating no internet connectivity.
  static const String animNoInternet = '$_animations/anim_no_internet.json';

  // ---------------------------------------------------------------------------
  // Fonts
  // ---------------------------------------------------------------------------

  /// Primary font family name (as registered in pubspec.yaml).
  static const String fontPrimary = 'Inter';

  /// Secondary / display font family name.
  static const String fontDisplay = 'Poppins';

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  /// Returns [imagePlaceholder] unless [path] is non-empty, in which case it
  /// returns [path] unchanged.
  static String imageOrPlaceholder(String? path) =>
      (path == null || path.isEmpty) ? imagePlaceholder : path;
}
