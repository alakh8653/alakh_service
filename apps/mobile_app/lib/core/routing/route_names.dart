/// Route name / path constants for the entire application.
///
/// Centralises every named route so that typos are caught at compile-time
/// rather than at runtime.
library route_names;

/// Route name and path constants.
///
/// Convention:
/// - [name]  – the GoRouter route *name* used with `context.goNamed(…)`
/// - [path]  – the URL path segment registered with `GoRoute(path: …)`
abstract final class RouteNames {
  RouteNames._();

  // ── Root ──────────────────────────────────────────────────────────────────

  static const String splash = 'splash';
  static const String splashPath = '/';

  static const String onboarding = 'onboarding';
  static const String onboardingPath = '/onboarding';

  // ── Auth ──────────────────────────────────────────────────────────────────

  static const String authRoot = 'auth';
  static const String authRootPath = '/auth';

  static const String login = 'login';
  static const String loginPath = 'login';

  static const String register = 'register';
  static const String registerPath = 'register';

  static const String forgotPassword = 'forgot-password';
  static const String forgotPasswordPath = 'forgot-password';

  static const String verifyOtp = 'verify-otp';
  static const String verifyOtpPath = 'verify-otp';

  // ── Main shell ────────────────────────────────────────────────────────────

  static const String mainShell = 'main';
  static const String mainShellPath = '/main';

  // ── Discovery ─────────────────────────────────────────────────────────────

  static const String discovery = 'discovery';
  static const String discoveryPath = 'discovery';

  static const String shopDetail = 'shop-detail';
  static const String shopDetailPath = 'shop-detail/:shopId';

  // ── Booking ───────────────────────────────────────────────────────────────

  static const String booking = 'booking';
  static const String bookingPath = 'booking';

  static const String bookingConfirm = 'booking-confirm';
  static const String bookingConfirmPath = 'booking-confirm/:bookingId';

  // ── Queue ─────────────────────────────────────────────────────────────────

  static const String queue = 'queue';
  static const String queuePath = 'queue';

  // ── Tracking ──────────────────────────────────────────────────────────────

  static const String tracking = 'tracking';
  static const String trackingPath = 'tracking/:jobId';

  // ── Payments ──────────────────────────────────────────────────────────────

  static const String payments = 'payments';
  static const String paymentsPath = 'payments';

  static const String paymentDetail = 'payment-detail';
  static const String paymentDetailPath = 'payment-detail/:paymentId';

  // ── Chat ──────────────────────────────────────────────────────────────────

  static const String chat = 'chat';
  static const String chatPath = 'chat';

  static const String chatRoom = 'chat-room';
  static const String chatRoomPath = 'chat-room/:roomId';

  // ── Profile ───────────────────────────────────────────────────────────────

  static const String profile = 'profile';
  static const String profilePath = 'profile';

  static const String editProfile = 'edit-profile';
  static const String editProfilePath = 'edit-profile';

  // ── Settings ──────────────────────────────────────────────────────────────

  static const String settings = 'settings';
  static const String settingsPath = 'settings';

  // ── Staff mode ────────────────────────────────────────────────────────────

  static const String staffMode = 'staff-mode';
  static const String staffModePath = '/staff';

  static const String staffDashboard = 'staff-dashboard';
  static const String staffDashboardPath = 'dashboard';

  static const String dispatch = 'dispatch';
  static const String dispatchPath = 'dispatch';

  // ── Notifications ─────────────────────────────────────────────────────────

  static const String notifications = 'notifications';
  static const String notificationsPath = 'notifications';

  // ── Error / fallback ──────────────────────────────────────────────────────

  static const String notFound = 'not-found';
  static const String notFoundPath = '/404';

  static const String error = 'error';
  static const String errorPath = '/error';
}
