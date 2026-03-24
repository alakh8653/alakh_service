import 'package:dartz/dartz.dart';

import '../entities/entities.dart';
import '../repositories/booking_repository.dart';
import '../../core/failures.dart';

/// Use case responsible for rescheduling an existing booking.
class RescheduleBookingUseCase {
  final BookingRepository _repository;

  const RescheduleBookingUseCase(this._repository);

  /// Executes the use case with the given [params].
  Future<Either<Failure, Booking>> call(RescheduleParams params) {
    return _repository.rescheduleBooking(params);
  }
}
