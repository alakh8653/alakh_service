/// App-wide string constants shared across all AlakhService apps.
class AppConstants {
  AppConstants._();

  // API
  static const String apiVersion = 'v1';
  static const int apiTimeoutSeconds = 30;
  static const int paginationPageSize = 20;

  // Regex
  static const String emailRegex =
      r'^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$';
  static const String phoneRegex = r'^[6-9]\d{9}$';
  static const String otpRegex = r'^\d{6}$';

  // Storage keys
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String onboardingCompleteKey = 'onboarding_complete';

  // Date formats
  static const String displayDateFormat = 'dd MMM yyyy';
  static const String displayTimeFormat = 'hh:mm a';

  // OTP
  static const int otpLength = 6;
  static const int otpResendSeconds = 30;

  // Booking
  static const int maxAdvanceBookingDays = 30;
}
