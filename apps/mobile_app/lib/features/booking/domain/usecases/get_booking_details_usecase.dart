import 'package:dartz/dartz.dart';

import '../entities/entities.dart';
import '../repositories/booking_repository.dart';
import '../../core/failures.dart';

/// Use case responsible for fetching full details of a single booking.
class GetBookingDetailsUseCase {
  final BookingRepository _repository;

  const GetBookingDetailsUseCase(this._repository);

  /// Executes the use case for [bookingId].
  Future<Either<Failure, Booking>> call(String bookingId) {
    return _repository.getBookingDetails(bookingId);
  }
}
