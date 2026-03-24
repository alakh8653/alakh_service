/// BLoC states for the bookings feature.
library;

import 'package:equatable/equatable.dart';
import 'package:shop_web/features/bookings/domain/entities/booking_filters.dart';
import 'package:shop_web/features/bookings/domain/entities/shop_booking.dart';

/// Base class for all booking BLoC states.
abstract class ShopBookingsState extends Equatable {
  const ShopBookingsState();
}

/// Initial state before any data has been requested.
class ShopBookingsInitial extends ShopBookingsState {
  const ShopBookingsInitial();

  @override
  List<Object> get props => [];
}

/// Emitted while a primary data load is in progress.
class ShopBookingsLoading extends ShopBookingsState {
  const ShopBookingsLoading();

  @override
  List<Object> get props => [];
}

/// Emitted when booking data is successfully loaded and ready to display.
class ShopBookingsLoaded extends ShopBookingsState {
  const ShopBookingsLoaded({
    required this.bookings,
    required this.totalCount,
    required this.currentFilters,
    this.calendarData,
  });

  final List<ShopBooking> bookings;

  /// Total number of records matching the current filter (for pagination).
  final int totalCount;

  final BookingFilters currentFilters;

  /// Populated when the calendar view has been loaded; `null` otherwise.
  final Map<DateTime, List<ShopBooking>>? calendarData;

  /// Convenience getter: number of pages given current [pageSize].
  int get totalPages =>
      (totalCount / currentFilters.pageSize).ceil().clamp(1, 9999);

  /// Returns a copy with specific fields replaced.
  ShopBookingsLoaded copyWith({
    List<ShopBooking>? bookings,
    int? totalCount,
    BookingFilters? currentFilters,
    Map<DateTime, List<ShopBooking>>? calendarData,
  }) {
    return ShopBookingsLoaded(
      bookings: bookings ?? this.bookings,
      totalCount: totalCount ?? this.totalCount,
      currentFilters: currentFilters ?? this.currentFilters,
      calendarData: calendarData ?? this.calendarData,
    );
  }

  @override
  List<Object?> get props =>
      [bookings, totalCount, currentFilters, calendarData];
}

/// Emitted when an error occurs during data loading or an action.
class ShopBookingsError extends ShopBookingsState {
  const ShopBookingsError(this.message);

  final String message;

  @override
  List<Object> get props => [message];
}

/// Emitted while a row-level action (cancel, confirm, etc.) is in progress.
///
/// Extends [ShopBookingsLoaded] so the table remains visible behind a spinner.
class BookingActionInProgress extends ShopBookingsLoaded {
  const BookingActionInProgress({
    required this.actionBookingId,
    required super.bookings,
    required super.totalCount,
    required super.currentFilters,
    super.calendarData,
  });

  /// The [ShopBooking.id] of the booking currently being acted upon.
  final String actionBookingId;

  @override
  List<Object?> get props => [...super.props, actionBookingId];
}
