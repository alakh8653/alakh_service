import 'package:dartz/dartz.dart';

import '../entities/entities.dart';
import '../repositories/booking_repository.dart';
import '../../core/failures.dart';

/// Parameters for cancelling a booking.
class CancelBookingParams {
  /// The booking to cancel.
  final String bookingId;

  /// Reason provided by the user for cancellation.
  final String reason;

  const CancelBookingParams({required this.bookingId, required this.reason});
}

/// Use case responsible for cancelling an existing booking.
class CancelBookingUseCase {
  final BookingRepository _repository;

  const CancelBookingUseCase(this._repository);

  /// Executes the use case with the given [params].
  Future<Either<Failure, Booking>> call(CancelBookingParams params) {
    return _repository.cancelBooking(params.bookingId, params.reason);
  }
}
