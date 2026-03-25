/// Analytics event name constants for the Shop Web application.
library;

/// Provides a single source of truth for all analytics event names logged
/// throughout the application.
///
/// Import this class wherever you call [ShopAnalyticsService.logEvent] to
/// avoid string typos.
abstract final class ShopAnalyticsEvents {
  // -------------------------------------------------------------------------
  // Screen views
  // -------------------------------------------------------------------------

  /// Fired when the main dashboard screen is displayed.
  static const String dashboardViewed = 'dashboard_viewed';

  /// Fired when the queue management screen is displayed.
  static const String queueViewed = 'queue_viewed';

  /// Fired when the bookings list screen is displayed.
  static const String bookingsViewed = 'bookings_viewed';

  /// Fired when the bookings calendar screen is displayed.
  static const String bookingCalendarViewed = 'booking_calendar_viewed';

  /// Fired when a single booking detail screen is displayed.
  static const String bookingDetailViewed = 'booking_detail_viewed';

  /// Fired when the staff list screen is displayed.
  static const String staffViewed = 'staff_viewed';

  /// Fired when an individual staff member's detail screen is displayed.
  static const String staffDetailViewed = 'staff_detail_viewed';

  /// Fired when the earnings overview screen is displayed.
  static const String earningsViewed = 'earnings_viewed';

  /// Fired when the analytics overview screen is displayed.
  static const String analyticsViewed = 'analytics_viewed';

  /// Fired when the settlements list screen is displayed.
  static const String settlementsViewed = 'settlements_viewed';

  /// Fired when a single settlement detail screen is displayed.
  static const String settlementDetailViewed = 'settlement_detail_viewed';

  /// Fired when the compliance screen is displayed.
  static const String complianceViewed = 'compliance_viewed';

  /// Fired when the settings screen is displayed.
  static const String settingsViewed = 'settings_viewed';

  /// Fired when the shop profile settings screen is displayed.
  static const String shopProfileViewed = 'shop_profile_viewed';

  /// Fired when the business hours settings screen is displayed.
  static const String businessHoursViewed = 'business_hours_viewed';

  /// Fired when the services settings screen is displayed.
  static const String servicesViewed = 'services_viewed';

  /// Fired when the notification settings screen is displayed.
  static const String notificationSettingsViewed = 'notification_settings_viewed';

  // -------------------------------------------------------------------------
  // Booking actions
  // -------------------------------------------------------------------------

  /// Fired when an operator confirms a pending booking.
  static const String bookingConfirmed = 'booking_confirmed';

  /// Fired when an operator cancels a booking.
  static const String bookingCancelled = 'booking_cancelled';

  /// Fired when an operator reschedules a booking.
  static const String bookingRescheduled = 'booking_rescheduled';

  // -------------------------------------------------------------------------
  // Queue actions
  // -------------------------------------------------------------------------

  /// Fired when the operator calls the next customer in the queue.
  static const String queueItemCalled = 'queue_item_called';

  /// Fired when the operator pauses the queue.
  static const String queuePaused = 'queue_paused';

  /// Fired when the operator resumes a paused queue.
  static const String queueResumed = 'queue_resumed';

  /// Fired when a queue item is manually reordered.
  static const String queueItemReordered = 'queue_item_reordered';

  /// Fired when queue settings are saved.
  static const String queueSettingsSaved = 'queue_settings_saved';

  // -------------------------------------------------------------------------
  // Staff actions
  // -------------------------------------------------------------------------

  /// Fired when an invitation is sent to a new staff member.
  static const String staffInvited = 'staff_invited';

  /// Fired when a staff member's details are updated.
  static const String staffUpdated = 'staff_updated';

  /// Fired when a staff member is removed from the shop.
  static const String staffRemoved = 'staff_removed';

  /// Fired when staff schedule changes are saved.
  static const String staffScheduleSaved = 'staff_schedule_saved';

  // -------------------------------------------------------------------------
  // Earnings & settlements
  // -------------------------------------------------------------------------

  /// Fired when the operator requests an early payout.
  static const String earlyPayoutRequested = 'early_payout_requested';

  /// Fired when the bank account is updated.
  static const String bankAccountUpdated = 'bank_account_updated';

  // -------------------------------------------------------------------------
  // Compliance
  // -------------------------------------------------------------------------

  /// Fired when the operator uploads a compliance document.
  static const String documentUploaded = 'document_uploaded';

  /// Fired when the operator deletes a compliance document.
  static const String documentDeleted = 'document_deleted';

  // -------------------------------------------------------------------------
  // Settings
  // -------------------------------------------------------------------------

  /// Fired when shop profile changes are saved.
  static const String shopProfileSaved = 'shop_profile_saved';

  /// Fired when business hours are updated.
  static const String businessHoursUpdated = 'business_hours_updated';

  /// Fired when a new service is added.
  static const String serviceAdded = 'service_added';

  /// Fired when an existing service is updated.
  static const String serviceUpdated = 'service_updated';

  /// Fired when a service is deleted.
  static const String serviceDeleted = 'service_deleted';

  /// Fired when notification preferences are saved.
  static const String notificationSettingsSaved = 'notification_settings_saved';

  // -------------------------------------------------------------------------
  // Auth
  // -------------------------------------------------------------------------

  /// Fired when an operator successfully logs in.
  static const String loginSuccess = 'login_success';

  /// Fired when a login attempt fails.
  static const String loginFailed = 'login_failed';

  /// Fired when the operator explicitly logs out.
  static const String logoutSuccess = 'logout_success';
}
