import 'package:equatable/equatable.dart';

import '../../domain/repositories/booking_repository.dart';

/// Base class for all booking BLoC events.
abstract class BookingEvent extends Equatable {
  const BookingEvent();

  @override
  List<Object?> get props => [];
}

/// Triggers loading of available time slots.
class LoadSlots extends BookingEvent {
  final String shopId;
  final String serviceId;
  final DateTime date;
  final String? staffId;

  const LoadSlots({
    required this.shopId,
    required this.serviceId,
    required this.date,
    this.staffId,
  });

  @override
  List<Object?> get props => [shopId, serviceId, date, staffId];
}

/// Triggers creation of a new booking.
class CreateBooking extends BookingEvent {
  final CreateBookingParams params;

  const CreateBooking(this.params);

  @override
  List<Object?> get props => [params];
}

/// Triggers cancellation of an existing booking.
class CancelBooking extends BookingEvent {
  final String bookingId;
  final String reason;

  const CancelBooking({required this.bookingId, required this.reason});

  @override
  List<Object?> get props => [bookingId, reason];
}

/// Triggers rescheduling of an existing booking.
class RescheduleBooking extends BookingEvent {
  final RescheduleParams params;

  const RescheduleBooking(this.params);

  @override
  List<Object?> get props => [params];
}

/// Triggers loading of all bookings for a user.
class LoadUserBookings extends BookingEvent {
  final String userId;

  const LoadUserBookings(this.userId);

  @override
  List<Object?> get props => [userId];
}

/// Triggers loading of the details for a specific booking.
class LoadBookingDetails extends BookingEvent {
  final String bookingId;

  const LoadBookingDetails(this.bookingId);

  @override
  List<Object?> get props => [bookingId];
}

/// Triggers loading of upcoming bookings for a user.
class LoadUpcomingBookings extends BookingEvent {
  final String userId;

  const LoadUpcomingBookings(this.userId);

  @override
  List<Object?> get props => [userId];
}
