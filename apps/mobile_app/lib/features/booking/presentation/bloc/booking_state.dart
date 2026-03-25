import 'package:equatable/equatable.dart';

import '../../domain/entities/entities.dart';

/// Base class for all booking BLoC states.
abstract class BookingState extends Equatable {
  const BookingState();

  @override
  List<Object?> get props => [];
}

/// The initial idle state before any events are dispatched.
class BookingInitial extends BookingState {
  const BookingInitial();
}

/// Indicates that available time slots are being fetched.
class SlotsLoading extends BookingState {
  const SlotsLoading();
}

/// Holds the successfully fetched time slots and the selected date.
class SlotsLoaded extends BookingState {
  final List<TimeSlot> slots;
  final DateTime selectedDate;

  const SlotsLoaded({required this.slots, required this.selectedDate});

  @override
  List<Object?> get props => [slots, selectedDate];
}

/// Indicates that a booking is being created.
class BookingCreating extends BookingState {
  const BookingCreating();
}

/// Indicates that a booking was successfully created.
class BookingCreated extends BookingState {
  final Booking booking;

  const BookingCreated(this.booking);

  @override
  List<Object?> get props => [booking];
}

/// Indicates that a booking was successfully cancelled.
class BookingCancelled extends BookingState {
  final Booking booking;

  const BookingCancelled(this.booking);

  @override
  List<Object?> get props => [booking];
}

/// Indicates that a booking was successfully rescheduled.
class BookingRescheduled extends BookingState {
  final Booking booking;

  const BookingRescheduled(this.booking);

  @override
  List<Object?> get props => [booking];
}

/// Holds a successfully fetched list of bookings.
class BookingsLoaded extends BookingState {
  final List<Booking> bookings;

  const BookingsLoaded(this.bookings);

  @override
  List<Object?> get props => [bookings];
}

/// Holds the full details of a single booking.
class BookingDetailsLoaded extends BookingState {
  final Booking booking;

  const BookingDetailsLoaded(this.booking);

  @override
  List<Object?> get props => [booking];
}

/// Holds a list of upcoming bookings.
class UpcomingBookingsLoaded extends BookingState {
  final List<Booking> bookings;

  const UpcomingBookingsLoaded(this.bookings);

  @override
  List<Object?> get props => [bookings];
}

/// Represents an error that occurred during a booking operation.
class BookingError extends BookingState {
  final String message;

  const BookingError(this.message);

  @override
  List<Object?> get props => [message];
}
