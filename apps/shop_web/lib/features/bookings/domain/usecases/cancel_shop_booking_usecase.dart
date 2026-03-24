/// Use-case: cancel an existing booking with a reason.
library;

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:shop_web/core/errors/shop_error_handler.dart';
import 'package:shop_web/features/bookings/domain/entities/shop_booking.dart';
import 'package:shop_web/features/bookings/domain/repositories/shop_bookings_repository.dart';

/// Parameters required to cancel a booking.
class CancelBookingParams extends Equatable {
  const CancelBookingParams({
    required this.id,
    required this.reason,
  });

  /// The unique identifier of the booking to cancel.
  final String id;

  /// A human-readable reason explaining why the booking is being cancelled.
  final String reason;

  @override
  List<Object> get props => [id, reason];
}

/// Cancels the booking identified by [CancelBookingParams.id], recording
/// the [CancelBookingParams.reason] on the server for audit purposes.
///
/// Returns the updated [ShopBooking] with status set to `cancelled`.
class CancelShopBookingUseCase
    extends UseCase<ShopBooking, CancelBookingParams> {
  const CancelShopBookingUseCase({required ShopBookingsRepository repository})
      : _repository = repository;

  final ShopBookingsRepository _repository;

  @override
  Future<Either<Failure, ShopBooking>> call(CancelBookingParams params) {
    return _repository.cancelBooking(params.id, params.reason);
  }
}
