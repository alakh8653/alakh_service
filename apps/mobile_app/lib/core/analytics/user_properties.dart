/// User property tracking.
library user_properties;

/// Constants for user property keys set on analytics providers.
abstract final class UserPropertyKeys {
  UserPropertyKeys._();

  static const String userId = 'user_id';
  static const String userType = 'user_type'; // 'customer' | 'staff'
  static const String planTier = 'plan_tier';
  static const String city = 'city';
  static const String appLanguage = 'app_language';
  static const String notificationsEnabled = 'notifications_enabled';
  static const String biometricsEnabled = 'biometrics_enabled';
  static const String totalBookings = 'total_bookings';
  static const String trustScore = 'trust_score';
  static const String isStaff = 'is_staff';
  static const String registrationDate = 'registration_date';
}

/// Snapshot of user properties to set on the analytics provider.
class UserProperties {
  const UserProperties({
    required this.userId,
    required this.userType,
    this.planTier,
    this.city,
    this.appLanguage,
    this.notificationsEnabled,
    this.biometricsEnabled,
    this.totalBookings,
    this.trustScore,
    this.registrationDate,
  });

  final String userId;

  /// Either `'customer'` or `'staff'`.
  final String userType;

  final String? planTier;
  final String? city;
  final String? appLanguage;
  final bool? notificationsEnabled;
  final bool? biometricsEnabled;
  final int? totalBookings;
  final double? trustScore;
  final DateTime? registrationDate;

  /// Converts to a flat [Map] suitable for passing to analytics SDKs.
  Map<String, dynamic> toMap() => {
        UserPropertyKeys.userId: userId,
        UserPropertyKeys.userType: userType,
        if (planTier != null) UserPropertyKeys.planTier: planTier,
        if (city != null) UserPropertyKeys.city: city,
        if (appLanguage != null) UserPropertyKeys.appLanguage: appLanguage,
        if (notificationsEnabled != null)
          UserPropertyKeys.notificationsEnabled: notificationsEnabled,
        if (biometricsEnabled != null)
          UserPropertyKeys.biometricsEnabled: biometricsEnabled,
        if (totalBookings != null)
          UserPropertyKeys.totalBookings: totalBookings,
        if (trustScore != null) UserPropertyKeys.trustScore: trustScore,
        if (registrationDate != null)
          UserPropertyKeys.registrationDate:
              registrationDate!.toIso8601String(),
      };
}
