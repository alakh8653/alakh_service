import 'package:dartz/dartz.dart';

import '../entities/entities.dart';
import '../repositories/booking_repository.dart';
import '../../core/failures.dart';

/// Use case responsible for fetching available time slots.
class GetAvailableSlotsUseCase {
  final BookingRepository _repository;

  const GetAvailableSlotsUseCase(this._repository);

  /// Executes the use case with the given [params].
  Future<Either<Failure, List<TimeSlot>>> call(SlotsParams params) {
    return _repository.getAvailableSlots(params);
  }
}
