/// API endpoint path constants.
///
/// Organises every backend endpoint by feature domain so that changes to
/// paths require edits in a single place.
library api_endpoints;

/// All REST API endpoint paths used by the mobile app.
///
/// Paths are relative to [AppConfig.fullBaseUrl].
/// Path parameters are represented as `{param}` placeholders.
abstract final class ApiEndpoints {
  ApiEndpoints._();

  // ── Auth ──────────────────────────────────────────────────────────────────

  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String logout = '/auth/logout';
  static const String refreshToken = '/auth/refresh';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';
  static const String verifyOtp = '/auth/verify-otp';
  static const String resendOtp = '/auth/resend-otp';

  // ── User / Profile ────────────────────────────────────────────────────────

  static const String me = '/users/me';
  static const String updateProfile = '/users/me';
  static const String uploadAvatar = '/users/me/avatar';
  static const String deleteAccount = '/users/me';
  static String userById(String id) => '/users/$id';

  // ── Onboarding ────────────────────────────────────────────────────────────

  static const String onboardingStatus = '/onboarding/status';
  static const String completeOnboarding = '/onboarding/complete';

  // ── Discovery ─────────────────────────────────────────────────────────────

  static const String shops = '/shops';
  static const String shopCategories = '/shops/categories';
  static String shopById(String id) => '/shops/$id';
  static String shopServices(String shopId) => '/shops/$shopId/services';
  static String shopStaff(String shopId) => '/shops/$shopId/staff';
  static String shopReviews(String shopId) => '/shops/$shopId/reviews';
  static String shopSlots(String shopId) => '/shops/$shopId/slots';

  // ── Booking ───────────────────────────────────────────────────────────────

  static const String bookings = '/bookings';
  static String bookingById(String id) => '/bookings/$id';
  static String cancelBooking(String id) => '/bookings/$id/cancel';
  static String rescheduleBooking(String id) => '/bookings/$id/reschedule';

  // ── Queue ─────────────────────────────────────────────────────────────────

  static const String queue = '/queue';
  static String joinQueue(String shopId) => '/shops/$shopId/queue/join';
  static String leaveQueue(String shopId) => '/shops/$shopId/queue/leave';
  static String queueStatus(String shopId) => '/shops/$shopId/queue/status';

  // ── Tracking ──────────────────────────────────────────────────────────────

  static String trackJob(String jobId) => '/jobs/$jobId/track';
  static String jobById(String id) => '/jobs/$id';

  // ── Payments ──────────────────────────────────────────────────────────────

  static const String payments = '/payments';
  static String paymentById(String id) => '/payments/$id';
  static const String initiatePayment = '/payments/initiate';
  static String confirmPayment(String id) => '/payments/$id/confirm';
  static String refundPayment(String id) => '/payments/$id/refund';
  static const String paymentMethods = '/payments/methods';

  // ── Chat ──────────────────────────────────────────────────────────────────

  static const String chatRooms = '/chat/rooms';
  static String chatRoom(String roomId) => '/chat/rooms/$roomId';
  static String chatMessages(String roomId) => '/chat/rooms/$roomId/messages';
  static String sendMessage(String roomId) => '/chat/rooms/$roomId/messages';

  // ── Notifications ─────────────────────────────────────────────────────────

  static const String notifications = '/notifications';
  static const String markAllRead = '/notifications/read-all';
  static String markRead(String id) => '/notifications/$id/read';
  static const String pushToken = '/notifications/push-token';

  // ── Reviews ───────────────────────────────────────────────────────────────

  static const String reviews = '/reviews';
  static String reviewById(String id) => '/reviews/$id';

  // ── Disputes ──────────────────────────────────────────────────────────────

  static const String disputes = '/disputes';
  static String disputeById(String id) => '/disputes/$id';

  // ── Referral ──────────────────────────────────────────────────────────────

  static const String referralCode = '/referral/code';
  static const String applyReferral = '/referral/apply';
  static const String referralStats = '/referral/stats';

  // ── Staff ─────────────────────────────────────────────────────────────────

  static const String staffDashboard = '/staff/dashboard';
  static const String staffJobs = '/staff/jobs';
  static String acceptJob(String id) => '/staff/jobs/$id/accept';
  static String rejectJob(String id) => '/staff/jobs/$id/reject';
  static String completeJob(String id) => '/staff/jobs/$id/complete';

  // ── Settings ──────────────────────────────────────────────────────────────

  static const String appSettings = '/settings';
  static const String supportedLanguages = '/settings/languages';

  // ── Analytics / trust ─────────────────────────────────────────────────────

  static const String trustScore = '/trust/score';
  static String userTrustScore(String userId) => '/trust/score/$userId';
}
