/// Predefined analytics event name constants for AlakhService.
///
/// Using constants prevents typos and makes refactoring easier.
abstract class AnalyticsEvents {
  AnalyticsEvents._();

  // ── Authentication ─────────────────────────────────────────────────────────
  static const String signUp = 'sign_up';
  static const String login = 'login';
  static const String logout = 'logout';
  static const String passwordReset = 'password_reset';

  // ── Onboarding ─────────────────────────────────────────────────────────────
  static const String onboardingStarted = 'onboarding_started';
  static const String onboardingCompleted = 'onboarding_completed';
  static const String onboardingSkipped = 'onboarding_skipped';

  // ── Service Discovery ──────────────────────────────────────────────────────
  static const String searchPerformed = 'search_performed';
  static const String categoryViewed = 'category_viewed';
  static const String serviceViewed = 'service_viewed';
  static const String shopViewed = 'shop_viewed';

  // ── Bookings ───────────────────────────────────────────────────────────────
  static const String bookingStarted = 'booking_started';
  static const String bookingCreated = 'booking_created';
  static const String bookingConfirmed = 'booking_confirmed';
  static const String bookingCancelled = 'booking_cancelled';
  static const String bookingCompleted = 'booking_completed';

  // ── Queue ──────────────────────────────────────────────────────────────────
  static const String queueJoined = 'queue_joined';
  static const String queueLeft = 'queue_left';
  static const String queuePositionUpdated = 'queue_position_updated';
  static const String queueCalled = 'queue_called';

  // ── Payments ───────────────────────────────────────────────────────────────
  static const String checkoutStarted = 'checkout_started';
  static const String paymentInitiated = 'payment_initiated';
  static const String paymentCompleted = 'payment_completed';
  static const String paymentFailed = 'payment_failed';
  static const String refundRequested = 'refund_requested';
  static const String walletTopUp = 'wallet_top_up';

  // ── Reviews ────────────────────────────────────────────────────────────────
  static const String reviewSubmitted = 'review_submitted';
  static const String reviewEdited = 'review_edited';

  // ── Chat ───────────────────────────────────────────────────────────────────
  static const String messageSent = 'message_sent';
  static const String conversationOpened = 'conversation_opened';

  // ── Referrals ─────────────────────────────────────────────────────────────
  static const String referralShared = 'referral_shared';
  static const String referralCodeApplied = 'referral_code_applied';

  // ── Notifications ─────────────────────────────────────────────────────────
  static const String notificationReceived = 'notification_received';
  static const String notificationTapped = 'notification_tapped';
  static const String notificationPermissionGranted =
      'notification_permission_granted';
  static const String notificationPermissionDenied =
      'notification_permission_denied';

  // ── Errors ────────────────────────────────────────────────────────────────
  static const String errorOccurred = 'error_occurred';
  static const String apiError = 'api_error';
}
