import 'package:dartz/dartz.dart';

import '../entities/entities.dart';
import '../repositories/booking_repository.dart';
import '../../core/failures.dart';

/// Use case responsible for fetching upcoming bookings for a user.
class GetUpcomingBookingsUseCase {
  final BookingRepository _repository;

  const GetUpcomingBookingsUseCase(this._repository);

  /// Executes the use case for [userId].
  Future<Either<Failure, List<Booking>>> call(String userId) {
    return _repository.getUpcomingBookings(userId);
  }
}
