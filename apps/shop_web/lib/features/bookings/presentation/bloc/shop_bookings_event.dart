/// BLoC events for the bookings feature.
library;

import 'package:equatable/equatable.dart';
import 'package:shop_web/features/bookings/domain/entities/booking_filters.dart';

/// Base class for all booking BLoC events.
abstract class ShopBookingsEvent extends Equatable {
  const ShopBookingsEvent();
}

/// Triggers a full booking list load with the given [filters].
class LoadBookings extends ShopBookingsEvent {
  const LoadBookings(this.filters);

  final BookingFilters filters;

  @override
  List<Object> get props => [filters];
}

/// Transitions booking [id] to [status].
class UpdateBookingStatus extends ShopBookingsEvent {
  const UpdateBookingStatus({required this.id, required this.status});

  final String id;
  final String status;

  @override
  List<Object> get props => [id, status];
}

/// Cancels booking [id] with [reason].
class CancelBooking extends ShopBookingsEvent {
  const CancelBooking({required this.id, required this.reason});

  final String id;
  final String reason;

  @override
  List<Object> get props => [id, reason];
}

/// Loads the monthly calendar view for [month].
class LoadBookingCalendar extends ShopBookingsEvent {
  const LoadBookingCalendar(this.month);

  final DateTime month;

  @override
  List<Object> get props => [month];
}

/// Applies [filters] and reloads the booking list from page 1.
class FilterBookings extends ShopBookingsEvent {
  const FilterBookings(this.filters);

  final BookingFilters filters;

  @override
  List<Object> get props => [filters];
}

/// Triggers a search using [query], resetting page to 1.
class SearchBookings extends ShopBookingsEvent {
  const SearchBookings(this.query);

  final String query;

  @override
  List<Object> get props => [query];
}

/// Navigates to [page] within the current filter context.
class ChangePage extends ShopBookingsEvent {
  const ChangePage(this.page);

  final int page;

  @override
  List<Object> get props => [page];
}

/// Sorts the booking list by [column] in the given direction.
class SortBookings extends ShopBookingsEvent {
  const SortBookings({required this.column, required this.ascending});

  final String column;
  final bool ascending;

  @override
  List<Object> get props => [column, ascending];
}
