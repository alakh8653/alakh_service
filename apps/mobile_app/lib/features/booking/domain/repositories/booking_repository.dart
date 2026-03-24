import 'package:dartz/dartz.dart';

import '../entities/entities.dart';
import '../../core/failures.dart';

/// Parameters for creating a new booking.
class CreateBookingParams {
  /// The user initiating the booking.
  final String userId;

  /// The shop where the service will be performed.
  final String shopId;

  /// The service to be performed.
  final String serviceId;

  /// The selected time slot identifier.
  final String timeSlotId;

  /// Optional staff preference.
  final String? staffId;

  /// Optional notes for the booking.
  final String? notes;

  const CreateBookingParams({
    required this.userId,
    required this.shopId,
    required this.serviceId,
    required this.timeSlotId,
    this.staffId,
    this.notes,
  });
}

/// Parameters for rescheduling an existing booking.
class RescheduleParams {
  /// Identifier of the booking to reschedule.
  final String bookingId;

  /// The new time slot identifier.
  final String newTimeSlotId;

  /// Optional reason for rescheduling.
  final String? reason;

  const RescheduleParams({
    required this.bookingId,
    required this.newTimeSlotId,
    this.reason,
  });
}

/// Parameters for fetching available slots.
class SlotsParams {
  /// Shop to query slots for.
  final String shopId;

  /// Service to query slots for.
  final String serviceId;

  /// The date for which to fetch slots.
  final DateTime date;

  /// Optional staff preference filter.
  final String? staffId;

  const SlotsParams({
    required this.shopId,
    required this.serviceId,
    required this.date,
    this.staffId,
  });
}

/// Abstract contract for booking-related data operations.
abstract class BookingRepository {
  /// Creates a new booking and returns the persisted [Booking].
  Future<Either<Failure, Booking>> createBooking(CreateBookingParams params);

  /// Cancels a booking by [bookingId] with an optional [reason].
  Future<Either<Failure, Booking>> cancelBooking(String bookingId, String reason);

  /// Reschedules an existing booking using [params].
  Future<Either<Failure, Booking>> rescheduleBooking(RescheduleParams params);

  /// Returns available [TimeSlot]s for the given [params].
  Future<Either<Failure, List<TimeSlot>>> getAvailableSlots(SlotsParams params);

  /// Returns all bookings belonging to [userId].
  Future<Either<Failure, List<Booking>>> getUserBookings(String userId);

  /// Returns the full details of a single booking by [bookingId].
  Future<Either<Failure, Booking>> getBookingDetails(String bookingId);

  /// Returns upcoming (confirmed/pending) bookings for [userId].
  Future<Either<Failure, List<Booking>>> getUpcomingBookings(String userId);
}
