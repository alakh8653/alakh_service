/// Analytics event name constants and event parameter models.
library analytics_events;

/// Centralised constants for all analytics event names.
abstract final class AnalyticsEventNames {
  AnalyticsEventNames._();

  // ── App lifecycle ─────────────────────────────────────────────────────────

  static const String appOpen = 'app_open';
  static const String appBackground = 'app_background';
  static const String appForeground = 'app_foreground';

  // ── Auth ──────────────────────────────────────────────────────────────────

  static const String login = 'login';
  static const String logout = 'logout';
  static const String register = 'sign_up';
  static const String loginFailed = 'login_failed';

  // ── Onboarding ────────────────────────────────────────────────────────────

  static const String onboardingStarted = 'onboarding_started';
  static const String onboardingStepCompleted = 'onboarding_step_completed';
  static const String onboardingCompleted = 'onboarding_completed';
  static const String onboardingSkipped = 'onboarding_skipped';

  // ── Discovery ─────────────────────────────────────────────────────────────

  static const String searchPerformed = 'search';
  static const String shopViewed = 'shop_viewed';
  static const String shopShared = 'shop_shared';
  static const String categorySelected = 'category_selected';

  // ── Booking ───────────────────────────────────────────────────────────────

  static const String bookingStarted = 'booking_started';
  static const String bookingConfirmed = 'booking_confirmed';
  static const String bookingCancelled = 'booking_cancelled';
  static const String bookingRescheduled = 'booking_rescheduled';

  // ── Queue ─────────────────────────────────────────────────────────────────

  static const String queueJoined = 'queue_joined';
  static const String queueLeft = 'queue_left';
  static const String queuePositionViewed = 'queue_position_viewed';

  // ── Payment ───────────────────────────────────────────────────────────────

  static const String paymentInitiated = 'payment_initiated';
  static const String paymentSuccess = 'payment_success';
  static const String paymentFailed = 'payment_failed';
  static const String paymentMethodAdded = 'payment_method_added';

  // ── Reviews ───────────────────────────────────────────────────────────────

  static const String reviewSubmitted = 'review_submitted';

  // ── Chat ──────────────────────────────────────────────────────────────────

  static const String chatOpened = 'chat_opened';
  static const String messageSent = 'message_sent';

  // ── Referral ──────────────────────────────────────────────────────────────

  static const String referralCodeShared = 'referral_code_shared';
  static const String referralApplied = 'referral_applied';

  // ── Notifications ─────────────────────────────────────────────────────────

  static const String notificationReceived = 'notification_received';
  static const String notificationTapped = 'notification_tapped';
  static const String notificationDismissed = 'notification_dismissed';

  // ── Settings ──────────────────────────────────────────────────────────────

  static const String themeChanged = 'theme_changed';
  static const String languageChanged = 'language_changed';

  // ── Error ─────────────────────────────────────────────────────────────────

  static const String errorDisplayed = 'error_displayed';
  static const String errorRetried = 'error_retried';
}

// ── Event parameter constants ─────────────────────────────────────────────────

/// Parameter key constants for event properties.
abstract final class AnalyticsParams {
  AnalyticsParams._();

  static const String method = 'method';
  static const String userId = 'user_id';
  static const String shopId = 'shop_id';
  static const String shopName = 'shop_name';
  static const String bookingId = 'booking_id';
  static const String paymentId = 'payment_id';
  static const String amount = 'amount';
  static const String currency = 'currency';
  static const String errorCode = 'error_code';
  static const String errorMessage = 'error_message';
  static const String screenName = 'screen_name';
  static const String step = 'step';
  static const String category = 'category';
  static const String searchQuery = 'search_query';
  static const String platform = 'platform';
}

// ── Typed event models ────────────────────────────────────────────────────────

/// Base class for typed analytics events.
abstract class AnalyticsEvent {
  const AnalyticsEvent({required this.name});

  final String name;

  /// Returns the event parameters map.
  Map<String, dynamic> toParameters();
}

/// Represents a booking-confirmed analytics event.
class BookingConfirmedEvent extends AnalyticsEvent {
  const BookingConfirmedEvent({
    required this.bookingId,
    required this.shopId,
    required this.amount,
    this.currency = 'INR',
  }) : super(name: AnalyticsEventNames.bookingConfirmed);

  final String bookingId;
  final String shopId;
  final double amount;
  final String currency;

  @override
  Map<String, dynamic> toParameters() => {
        AnalyticsParams.bookingId: bookingId,
        AnalyticsParams.shopId: shopId,
        AnalyticsParams.amount: amount,
        AnalyticsParams.currency: currency,
      };
}

/// Represents a payment-success analytics event.
class PaymentSuccessEvent extends AnalyticsEvent {
  const PaymentSuccessEvent({
    required this.paymentId,
    required this.amount,
    this.currency = 'INR',
    required this.method,
  }) : super(name: AnalyticsEventNames.paymentSuccess);

  final String paymentId;
  final double amount;
  final String currency;
  final String method;

  @override
  Map<String, dynamic> toParameters() => {
        AnalyticsParams.paymentId: paymentId,
        AnalyticsParams.amount: amount,
        AnalyticsParams.currency: currency,
        AnalyticsParams.method: method,
      };
}

/// Represents a search analytics event.
class SearchEvent extends AnalyticsEvent {
  const SearchEvent({
    required this.query,
    this.category,
    this.resultCount,
  }) : super(name: AnalyticsEventNames.searchPerformed);

  final String query;
  final String? category;
  final int? resultCount;

  @override
  Map<String, dynamic> toParameters() => {
        AnalyticsParams.searchQuery: query,
        if (category != null) AnalyticsParams.category: category,
        if (resultCount != null) 'result_count': resultCount,
      };
}
