/// Abstract repository contract for bookings feature.
library;

import 'package:dartz/dartz.dart';
import 'package:shop_web/core/errors/shop_error_handler.dart';
import 'package:shop_web/features/bookings/domain/entities/booking_filters.dart';
import 'package:shop_web/features/bookings/domain/entities/shop_booking.dart';

/// Defines all data operations available for the bookings feature.
///
/// Implementations may source data from a remote API, local cache, or a
/// combination of both.  All methods return [Either] so that callers can
/// handle [Failure] cases without catching exceptions.
abstract class ShopBookingsRepository {
  /// Fetches a page of bookings matching [filters].
  ///
  /// Returns a tuple of the matching booking list and the total record count
  /// (used for pagination calculations).
  Future<Either<Failure, (List<ShopBooking>, int)>> getBookings(
    BookingFilters filters,
  );

  /// Retrieves a single booking identified by [id].
  Future<Either<Failure, ShopBooking>> getBookingById(String id);

  /// Transitions the booking with [id] to [status].
  ///
  /// Valid status values: `confirmed`, `pending`, `completed`,
  /// `cancelled`, `noShow`.
  Future<Either<Failure, ShopBooking>> updateBookingStatus(
    String id,
    String status,
  );

  /// Cancels the booking with [id], recording the [reason].
  Future<Either<Failure, ShopBooking>> cancelBooking(
    String id,
    String reason,
  );

  /// Retrieves bookings grouped by calendar day for the given [month].
  ///
  /// The keys of the returned map are normalised to midnight UTC of each day.
  Future<Either<Failure, Map<DateTime, List<ShopBooking>>>> getBookingCalendar(
    DateTime month,
  );
}
