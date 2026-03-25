/// Cache key constants.
///
/// All keys used with [CacheManager] are defined here to prevent typos and
/// collisions.
library cache_keys;

/// Centralised constants for every cache entry.
abstract final class CacheKeys {
  CacheKeys._();

  // ── Auth / session ────────────────────────────────────────────────────────

  static const String accessToken = 'auth_access_token';
  static const String refreshToken = 'auth_refresh_token';
  static const String currentUserId = 'auth_current_user_id';
  static const String currentUser = 'auth_current_user';

  // ── Onboarding ────────────────────────────────────────────────────────────

  static const String onboardingCompleted = 'onboarding_completed';
  static const String onboardingStep = 'onboarding_step';

  // ── Discovery ─────────────────────────────────────────────────────────────

  static const String shopListPrefix = 'shop_list_';
  static String shopList(String query) => '$shopListPrefix$query';

  static const String shopDetailPrefix = 'shop_detail_';
  static String shopDetail(String shopId) => '$shopDetailPrefix$shopId';

  // ── Booking ───────────────────────────────────────────────────────────────

  static const String bookingList = 'booking_list';
  static const String bookingDetailPrefix = 'booking_detail_';
  static String bookingDetail(String bookingId) =>
      '$bookingDetailPrefix$bookingId';

  // ── Queue ─────────────────────────────────────────────────────────────────

  static const String queueStatusPrefix = 'queue_status_';
  static String queueStatus(String shopId) => '$queueStatusPrefix$shopId';

  // ── Profile ───────────────────────────────────────────────────────────────

  static const String userProfile = 'user_profile';

  // ── Settings ──────────────────────────────────────────────────────────────

  static const String appThemeMode = 'settings_theme_mode';
  static const String appLocale = 'settings_locale';
  static const String notificationsEnabled = 'settings_notifications_enabled';
  static const String biometricsEnabled = 'settings_biometrics_enabled';

  // ── Misc ─────────────────────────────────────────────────────────────────

  static const String appVersion = 'misc_app_version';
  static const String fcmToken = 'misc_fcm_token';
  static const String lastSyncTimestamp = 'misc_last_sync_ts';

  // ── TTL metadata ──────────────────────────────────────────────────────────

  /// Returns the TTL-expiry key for a given cache [key].
  static String expiryKey(String key) => '${key}_expiry';
}
