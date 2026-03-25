class ApiEndpoints {
  ApiEndpoints._();

  // Auth
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String logout = '/auth/logout';
  static const String refreshToken = '/auth/refresh';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';

  // Users
  static const String userProfile = '/users/me';
  static const String updateProfile = '/users/me';
  static const String updateAvatar = '/users/me/avatar';

  // Shops
  static const String shops = '/shops';
  static const String shopById = '/shops/{id}';
  static const String nearbyShops = '/shops/nearby';
  static const String shopServices = '/shops/{id}/services';

  // Services
  static const String services = '/services';
  static const String serviceById = '/services/{id}';

  // Bookings
  static const String bookings = '/bookings';
  static const String bookingById = '/bookings/{id}';
  static const String cancelBooking = '/bookings/{id}/cancel';

  // Queue
  static const String queueStatus = '/queue/{shopId}/status';
  static const String joinQueue = '/queue/{shopId}/join';
  static const String leaveQueue = '/queue/{shopId}/leave';

  // Payments
  static const String createPayment = '/payments/create';
  static const String verifyPayment = '/payments/verify';
  static const String paymentHistory = '/payments/history';

  // Dispatch
  static const String dispatchStatus = '/dispatch/{bookingId}/status';
  static const String trackDispatch = '/dispatch/{bookingId}/track';

  // Notifications
  static const String registerDevice = '/notifications/device';
  static const String notificationHistory = '/notifications/history';
}
