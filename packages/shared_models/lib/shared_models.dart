/// Shared data models and entities used across all apps in alakh_service.
///
/// Import this library to access all shared model classes:
/// ```dart
/// import 'package:shared_models/shared_models.dart';
/// ```
library shared_models;

// User
export 'src/user/user.dart';
export 'src/user/user_role.dart';

// Shop
export 'src/shop/shop.dart';
export 'src/shop/shop_category.dart';

// Booking
export 'src/booking/booking.dart';
export 'src/booking/booking_status.dart';

// Service
export 'src/service/service.dart';

// Payment
export 'src/payment/payment.dart';
export 'src/payment/payment_method_type.dart';
export 'src/payment/payment_status.dart';

// Review
export 'src/review/review.dart';

// Location
export 'src/location/address.dart';
export 'src/location/coordinates.dart';

// Common
export 'src/common/api_error.dart';
export 'src/common/date_range.dart';
export 'src/common/money.dart';
export 'src/common/paginated_response.dart';
export 'src/common/result.dart';
