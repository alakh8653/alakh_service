/// Use-case: update the status of an existing booking.
library;

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:shop_web/core/errors/shop_error_handler.dart';
import 'package:shop_web/features/bookings/domain/entities/shop_booking.dart';
import 'package:shop_web/features/bookings/domain/repositories/shop_bookings_repository.dart';

/// Parameters required to transition a booking to a new lifecycle status.
class UpdateBookingStatusParams extends Equatable {
  const UpdateBookingStatusParams({
    required this.id,
    required this.status,
  });

  /// The unique identifier of the booking to update.
  final String id;

  /// The target status value; one of `confirmed`, `completed`,
  /// `cancelled`, `pending`, `noShow`.
  final String status;

  @override
  List<Object> get props => [id, status];
}

/// Transitions a booking identified by [UpdateBookingStatusParams.id]
/// to the supplied [UpdateBookingStatusParams.status].
class UpdateBookingStatusUseCase
    extends UseCase<ShopBooking, UpdateBookingStatusParams> {
  const UpdateBookingStatusUseCase({required ShopBookingsRepository repository})
      : _repository = repository;

  final ShopBookingsRepository _repository;

  @override
  Future<Either<Failure, ShopBooking>> call(
    UpdateBookingStatusParams params,
  ) {
    return _repository.updateBookingStatus(params.id, params.status);
  }
}
