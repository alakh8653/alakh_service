/// Use-case: fetch a paginated list of bookings.
library;

import 'package:dartz/dartz.dart';
import 'package:shop_web/core/errors/shop_error_handler.dart';
import 'package:shop_web/features/bookings/domain/entities/booking_filters.dart';
import 'package:shop_web/features/bookings/domain/entities/shop_booking.dart';
import 'package:shop_web/features/bookings/domain/repositories/shop_bookings_repository.dart';

/// Retrieves a filtered and paginated list of [ShopBooking] records along
/// with the total matching count for pagination UI.
///
/// The tuple `(List<ShopBooking>, int)` contains:
/// - the current page of bookings
/// - the total number of records matching the current filter
class GetShopBookingsUseCase
    extends UseCase<(List<ShopBooking>, int), BookingFilters> {
  const GetShopBookingsUseCase({required ShopBookingsRepository repository})
      : _repository = repository;

  final ShopBookingsRepository _repository;

  /// Executes the use-case with the provided [params] filters.
  @override
  Future<Either<Failure, (List<ShopBooking>, int)>> call(
    BookingFilters params,
  ) {
    return _repository.getBookings(params);
  }
}
