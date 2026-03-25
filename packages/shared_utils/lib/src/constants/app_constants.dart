class AppConstants {
  AppConstants._();

  // Timeouts
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration debounceDelay = Duration(milliseconds: 500);

  // Pagination
  static const int defaultPageSize = 10;
  static const int maxPageSize = 50;

  // Storage keys
  static const String themeKey = 'app_theme';
  static const String localeKey = 'app_locale';
  static const String onboardingKey = 'onboarding_complete';

  // Map
  static const double defaultLatitude = 20.5937;
  static const double defaultLongitude = 78.9629;
  static const double defaultMapZoom = 14.0;

  // Validation
  static const int minPasswordLength = 8;
  static const int maxNameLength = 50;
  static const int phoneLength = 10;
  static const int pincodeLength = 6;

  // Image
  static const double avatarRadius = 24.0;
  static const double cardBorderRadius = 12.0;
}
