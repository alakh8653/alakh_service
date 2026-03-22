/// Key constants for SharedPreferences, Hive boxes, and Flutter Secure Storage.
library;

/// Centralised collection of storage keys so that typos are caught at
/// compile time rather than at runtime.
abstract final class StorageKeys {
  // ---------------------------------------------------------------------------
  // Authentication
  // ---------------------------------------------------------------------------

  /// JWT access token for API calls.
  static const String accessToken = 'auth.access_token';

  /// JWT refresh token used to silently renew sessions.
  static const String refreshToken = 'auth.refresh_token';

  /// Timestamp (ISO-8601) when the access token expires.
  static const String tokenExpiry = 'auth.token_expiry';

  /// Serialised [User] object of the currently authenticated user.
  static const String currentUser = 'auth.current_user';

  /// Whether the user has completed the onboarding flow.
  static const String onboardingCompleted = 'auth.onboarding_completed';

  // ---------------------------------------------------------------------------
  // User Preferences
  // ---------------------------------------------------------------------------

  /// Selected app locale/language code (e.g. `"en"`, `"hi"`).
  static const String appLocale = 'prefs.locale';

  /// Selected theme mode: `"system"`, `"light"`, or `"dark"`.
  static const String themeMode = 'prefs.theme_mode';

  /// Whether push notifications are enabled by the user.
  static const String notificationsEnabled = 'prefs.notifications_enabled';

  /// Whether location access is granted by the user.
  static const String locationEnabled = 'prefs.location_enabled';

  /// User's last known latitude.
  static const String lastLatitude = 'prefs.last_latitude';

  /// User's last known longitude.
  static const String lastLongitude = 'prefs.last_longitude';

  /// Currency code selected by the user (e.g. `"INR"`, `"USD"`).
  static const String currencyCode = 'prefs.currency_code';

  // ---------------------------------------------------------------------------
  // App State
  // ---------------------------------------------------------------------------

  /// App version string at the time of last launch (used to detect upgrades).
  static const String lastAppVersion = 'app.last_version';

  /// Number of times the app has been launched.
  static const String launchCount = 'app.launch_count';

  /// Whether the user has already been shown the rating prompt.
  static const String ratingPromptShown = 'app.rating_prompt_shown';

  /// ISO-8601 timestamp of the last successful data sync.
  static const String lastSyncTimestamp = 'app.last_sync_timestamp';

  // ---------------------------------------------------------------------------
  // Feature-specific
  // ---------------------------------------------------------------------------

  /// Serialised list of recent search queries.
  static const String recentSearches = 'search.recent_queries';

  /// Serialised list of saved address IDs.
  static const String savedAddressIds = 'user.saved_address_ids';

  /// ID of the user's currently selected / default address.
  static const String defaultAddressId = 'user.default_address_id';

  /// Serialised list of favourite shop IDs.
  static const String favouriteShopIds = 'user.favourite_shop_ids';

  /// Cached FCM / push notification device token.
  static const String devicePushToken = 'device.push_token';

  /// Unique device identifier generated on first launch.
  static const String deviceId = 'device.id';

  // ---------------------------------------------------------------------------
  // Biometrics / Security
  // ---------------------------------------------------------------------------

  /// Whether the user has enabled biometric authentication.
  static const String biometricEnabled = 'security.biometric_enabled';

  /// Whether the PIN lock is active.
  static const String pinLockEnabled = 'security.pin_lock_enabled';

  // ---------------------------------------------------------------------------
  // Cart / Draft
  // ---------------------------------------------------------------------------

  /// Serialised draft booking data (persisted across app restarts).
  static const String draftBooking = 'booking.draft';
}
