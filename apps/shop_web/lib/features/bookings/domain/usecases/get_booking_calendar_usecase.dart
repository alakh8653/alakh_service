/// Use-case: load calendar data for a specific month.
library;

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:shop_web/core/errors/shop_error_handler.dart';
import 'package:shop_web/features/bookings/domain/entities/shop_booking.dart';
import 'package:shop_web/features/bookings/domain/repositories/shop_bookings_repository.dart';

/// Parameters identifying the calendar month to load.
class CalendarParams extends Equatable {
  const CalendarParams({required this.month});

  /// Any [DateTime] within the desired month; only year and month are used.
  final DateTime month;

  @override
  List<Object> get props => [month.year, month.month];
}

/// Fetches all bookings for the month specified by [CalendarParams.month],
/// returned as a map keyed on normalised day [DateTime] values.
///
/// Useful for rendering a monthly calendar grid that shows booking
/// counts and allows drill-down into individual days.
class GetBookingCalendarUseCase
    extends UseCase<Map<DateTime, List<ShopBooking>>, CalendarParams> {
  const GetBookingCalendarUseCase({required ShopBookingsRepository repository})
      : _repository = repository;

  final ShopBookingsRepository _repository;

  @override
  Future<Either<Failure, Map<DateTime, List<ShopBooking>>>> call(
    CalendarParams params,
  ) {
    return _repository.getBookingCalendar(params.month);
  }
}
