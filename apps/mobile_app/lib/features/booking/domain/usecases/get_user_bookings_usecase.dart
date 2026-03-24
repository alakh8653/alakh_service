import 'package:dartz/dartz.dart';

import '../entities/entities.dart';
import '../repositories/booking_repository.dart';
import '../../core/failures.dart';

/// Use case responsible for fetching all bookings for a user.
class GetUserBookingsUseCase {
  final BookingRepository _repository;

  const GetUserBookingsUseCase(this._repository);

  /// Executes the use case for [userId].
  Future<Either<Failure, List<Booking>>> call(String userId) {
    return _repository.getUserBookings(userId);
  }
}
