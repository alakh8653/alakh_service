/// Global application-wide constants.
library;

/// Contains all global app-level constants used across the mobile application.
class AppConstants {
  AppConstants._();

  // ---------------------------------------------------------------------------
  // Pagination
  // ---------------------------------------------------------------------------

  /// Default number of items per page in paginated lists.
  static const int defaultPageSize = 20;

  /// Maximum number of items per page allowed by the API.
  static const int maxPageSize = 100;

  /// Page number to start pagination from.
  static const int initialPage = 1;

  // ---------------------------------------------------------------------------
  // Network / Timeout
  // ---------------------------------------------------------------------------

  /// Default HTTP connection timeout in seconds.
  static const Duration connectTimeout = Duration(seconds: 30);

  /// Default HTTP receive timeout in seconds.
  static const Duration receiveTimeout = Duration(seconds: 30);

  /// Default HTTP send timeout in seconds.
  static const Duration sendTimeout = Duration(seconds: 30);

  /// Number of times a failed network request is retried.
  static const int maxRetryAttempts = 3;

  /// Delay between retry attempts.
  static const Duration retryDelay = Duration(seconds: 2);

  // ---------------------------------------------------------------------------
  // Animation durations
  // ---------------------------------------------------------------------------

  /// Fast transition (e.g., button press feedback).
  static const Duration animationFast = Duration(milliseconds: 150);

  /// Normal transition (e.g., route transitions).
  static const Duration animationNormal = Duration(milliseconds: 300);

  /// Slow transition (e.g., full-screen modal).
  static const Duration animationSlow = Duration(milliseconds: 500);

  // ---------------------------------------------------------------------------
  // Search / Debounce
  // ---------------------------------------------------------------------------

  /// Debounce duration for search inputs.
  static const Duration searchDebounce = Duration(milliseconds: 400);

  /// Minimum number of characters before triggering a search.
  static const int searchMinLength = 2;

  // ---------------------------------------------------------------------------
  // Image / Media
  // ---------------------------------------------------------------------------

  /// Maximum file size for image uploads (5 MB).
  static const int maxImageSizeBytes = 5 * 1024 * 1024;

  /// Maximum file size for video uploads (50 MB).
  static const int maxVideoSizeBytes = 50 * 1024 * 1024;

  /// Image quality used when compressing uploaded images (0–100).
  static const int imageCompressionQuality = 85;

  // ---------------------------------------------------------------------------
  // Cache
  // ---------------------------------------------------------------------------

  /// Default time-to-live for in-memory cached data.
  static const Duration defaultCacheTtl = Duration(minutes: 5);

  /// TTL for user profile data in cache.
  static const Duration profileCacheTtl = Duration(minutes: 15);

  // ---------------------------------------------------------------------------
  // Session
  // ---------------------------------------------------------------------------

  /// Duration after which an idle session is considered expired.
  static const Duration sessionTimeout = Duration(hours: 24);

  /// Duration before token expiry to trigger a silent refresh.
  static const Duration tokenRefreshBuffer = Duration(minutes: 5);

  // ---------------------------------------------------------------------------
  // Ratings
  // ---------------------------------------------------------------------------

  /// Maximum star rating value.
  static const int maxRating = 5;

  /// Minimum star rating value.
  static const int minRating = 1;

  // ---------------------------------------------------------------------------
  // OTP
  // ---------------------------------------------------------------------------

  /// Length of OTP codes sent to users.
  static const int otpLength = 6;

  /// Duration before an OTP expires.
  static const Duration otpExpiry = Duration(minutes: 10);

  /// Cooldown before allowing a resend of OTP.
  static const Duration otpResendCooldown = Duration(seconds: 60);

  // ---------------------------------------------------------------------------
  // Misc
  // ---------------------------------------------------------------------------

  /// Maximum number of addresses a user can save.
  static const int maxSavedAddresses = 5;

  /// Maximum number of favourite shops.
  static const int maxFavouriteShops = 50;

  /// Radius (in km) used for nearby shop discovery.
  static const double defaultDiscoveryRadius = 10.0;
}
