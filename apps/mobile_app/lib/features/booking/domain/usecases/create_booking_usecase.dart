import 'package:dartz/dartz.dart';

import '../entities/entities.dart';
import '../repositories/booking_repository.dart';
import '../../core/failures.dart';

/// Use case responsible for creating a new booking.
class CreateBookingUseCase {
  final BookingRepository _repository;

  const CreateBookingUseCase(this._repository);

  /// Executes the use case with the given [params].
  Future<Either<Failure, Booking>> call(CreateBookingParams params) {
    return _repository.createBooking(params);
  }
}
