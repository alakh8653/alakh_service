/// Route name constants for the Shop Web application.
library;

/// Provides a single source of truth for all named GoRouter routes.
///
/// Use these constants in [context.goNamed], [context.pushNamed], and route
/// definitions to prevent string-literal typos.
abstract final class ShopRouteNames {
  // -------------------------------------------------------------------------
  // Auth
  // -------------------------------------------------------------------------

  /// The operator login screen.
  static const String login = 'login';

  // -------------------------------------------------------------------------
  // Dashboard
  // -------------------------------------------------------------------------

  /// The main dashboard overview screen.
  static const String dashboard = 'dashboard';

  // -------------------------------------------------------------------------
  // Queue
  // -------------------------------------------------------------------------

  /// The real-time queue management screen.
  static const String queue = 'queue';

  // -------------------------------------------------------------------------
  // Bookings
  // -------------------------------------------------------------------------

  /// The bookings list screen.
  static const String bookings = 'bookings';

  /// The bookings calendar view screen.
  static const String bookingCalendar = 'booking-calendar';

  /// The detail screen for a single booking (requires `:id` path param).
  static const String bookingDetail = 'booking-detail';

  // -------------------------------------------------------------------------
  // Staff
  // -------------------------------------------------------------------------

  /// The staff list screen.
  static const String staff = 'staff';

  /// The detail / edit screen for a single staff member (requires `:id` path param).
  static const String staffDetail = 'staff-detail';

  /// The screen for inviting a new staff member.
  static const String staffInvite = 'staff-invite';

  // -------------------------------------------------------------------------
  // Earnings
  // -------------------------------------------------------------------------

  /// The earnings overview screen.
  static const String earnings = 'earnings';

  // -------------------------------------------------------------------------
  // Analytics
  // -------------------------------------------------------------------------

  /// The analytics & insights screen.
  static const String analytics = 'analytics';

  // -------------------------------------------------------------------------
  // Settlements
  // -------------------------------------------------------------------------

  /// The settlements list screen.
  static const String settlements = 'settlements';

  /// The detail screen for a single settlement (requires `:id` path param).
  static const String settlementDetail = 'settlement-detail';

  /// The bank account settings screen.
  static const String bankSettings = 'bank-settings';

  // -------------------------------------------------------------------------
  // Compliance
  // -------------------------------------------------------------------------

  /// The compliance status and document list screen.
  static const String compliance = 'compliance';

  /// The document upload screen.
  static const String uploadDocument = 'upload-document';

  // -------------------------------------------------------------------------
  // Settings
  // -------------------------------------------------------------------------

  /// The top-level settings screen.
  static const String settings = 'settings';

  /// The shop public profile editor.
  static const String shopProfile = 'shop-profile';

  /// The business hours editor.
  static const String businessHours = 'business-hours';

  /// The services / menu editor.
  static const String services = 'services';

  /// The notification preferences screen.
  static const String notificationSettings = 'notification-settings';
}
