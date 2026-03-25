/// BLoC orchestrating all booking list, action, and calendar operations.
library;

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shop_web/features/bookings/domain/entities/booking_filters.dart';
import 'package:shop_web/features/bookings/domain/usecases/cancel_shop_booking_usecase.dart';
import 'package:shop_web/features/bookings/domain/usecases/get_booking_calendar_usecase.dart';
import 'package:shop_web/features/bookings/domain/usecases/get_shop_bookings_usecase.dart';
import 'package:shop_web/features/bookings/domain/usecases/update_booking_status_usecase.dart';
import 'package:shop_web/features/bookings/presentation/bloc/shop_bookings_event.dart';
import 'package:shop_web/features/bookings/presentation/bloc/shop_bookings_state.dart';

/// Manages the complete lifecycle of the bookings list, filters, pagination,
/// sorting, row actions and calendar data.
class ShopBookingsBloc extends Bloc<ShopBookingsEvent, ShopBookingsState> {
  ShopBookingsBloc({
    required GetShopBookingsUseCase getBookings,
    required UpdateBookingStatusUseCase updateBookingStatus,
    required CancelShopBookingUseCase cancelBooking,
    required GetBookingCalendarUseCase getBookingCalendar,
  })  : _getBookings = getBookings,
        _updateBookingStatus = updateBookingStatus,
        _cancelBooking = cancelBooking,
        _getBookingCalendar = getBookingCalendar,
        super(const ShopBookingsInitial()) {
    on<LoadBookings>(_onLoadBookings);
    on<FilterBookings>(_onFilterBookings);
    on<SearchBookings>(_onSearchBookings);
    on<ChangePage>(_onChangePage);
    on<SortBookings>(_onSortBookings);
    on<UpdateBookingStatus>(_onUpdateBookingStatus);
    on<CancelBooking>(_onCancelBooking);
    on<LoadBookingCalendar>(_onLoadBookingCalendar);
  }

  final GetShopBookingsUseCase _getBookings;
  final UpdateBookingStatusUseCase _updateBookingStatus;
  final CancelShopBookingUseCase _cancelBooking;
  final GetBookingCalendarUseCase _getBookingCalendar;

  Future<void> _onLoadBookings(
    LoadBookings event,
    Emitter<ShopBookingsState> emit,
  ) async {
    emit(const ShopBookingsLoading());
    final result = await _getBookings(event.filters);
    result.fold(
      (failure) => emit(ShopBookingsError(failure.message)),
      (data) => emit(ShopBookingsLoaded(
        bookings: data.$1,
        totalCount: data.$2,
        currentFilters: event.filters,
      )),
    );
  }

  Future<void> _onFilterBookings(
    FilterBookings event,
    Emitter<ShopBookingsState> emit,
  ) async {
    final filters = event.filters.resetPage();
    emit(const ShopBookingsLoading());
    final result = await _getBookings(filters);
    result.fold(
      (failure) => emit(ShopBookingsError(failure.message)),
      (data) => emit(ShopBookingsLoaded(
        bookings: data.$1,
        totalCount: data.$2,
        currentFilters: filters,
      )),
    );
  }

  Future<void> _onSearchBookings(
    SearchBookings event,
    Emitter<ShopBookingsState> emit,
  ) async {
    final current = state is ShopBookingsLoaded
        ? (state as ShopBookingsLoaded).currentFilters
        : BookingFilters.initial();
    final filters =
        current.copyWith(searchQuery: event.query).resetPage();
    emit(const ShopBookingsLoading());
    final result = await _getBookings(filters);
    result.fold(
      (failure) => emit(ShopBookingsError(failure.message)),
      (data) => emit(ShopBookingsLoaded(
        bookings: data.$1,
        totalCount: data.$2,
        currentFilters: filters,
      )),
    );
  }

  Future<void> _onChangePage(
    ChangePage event,
    Emitter<ShopBookingsState> emit,
  ) async {
    if (state is! ShopBookingsLoaded) return;
    final loaded = state as ShopBookingsLoaded;
    final filters = loaded.currentFilters.copyWith(page: event.page);
    emit(const ShopBookingsLoading());
    final result = await _getBookings(filters);
    result.fold(
      (failure) => emit(ShopBookingsError(failure.message)),
      (data) => emit(loaded.copyWith(
        bookings: data.$1,
        totalCount: data.$2,
        currentFilters: filters,
      )),
    );
  }

  Future<void> _onSortBookings(
    SortBookings event,
    Emitter<ShopBookingsState> emit,
  ) async {
    if (state is! ShopBookingsLoaded) return;
    final loaded = state as ShopBookingsLoaded;
    final filters = loaded.currentFilters
        .copyWith(sortBy: event.column, sortAsc: event.ascending)
        .resetPage();
    emit(const ShopBookingsLoading());
    final result = await _getBookings(filters);
    result.fold(
      (failure) => emit(ShopBookingsError(failure.message)),
      (data) => emit(loaded.copyWith(
        bookings: data.$1,
        totalCount: data.$2,
        currentFilters: filters,
      )),
    );
  }

  Future<void> _onUpdateBookingStatus(
    UpdateBookingStatus event,
    Emitter<ShopBookingsState> emit,
  ) async {
    if (state is! ShopBookingsLoaded) return;
    final loaded = state as ShopBookingsLoaded;
    emit(BookingActionInProgress(
      actionBookingId: event.id,
      bookings: loaded.bookings,
      totalCount: loaded.totalCount,
      currentFilters: loaded.currentFilters,
      calendarData: loaded.calendarData,
    ));
    final result = await _updateBookingStatus(
      UpdateBookingStatusParams(id: event.id, status: event.status),
    );
    result.fold(
      (failure) => emit(ShopBookingsError(failure.message)),
      (updated) {
        final updatedList = loaded.bookings
            .map((b) => b.id == updated.id ? updated : b)
            .toList();
        emit(loaded.copyWith(bookings: updatedList));
      },
    );
  }

  Future<void> _onCancelBooking(
    CancelBooking event,
    Emitter<ShopBookingsState> emit,
  ) async {
    if (state is! ShopBookingsLoaded) return;
    final loaded = state as ShopBookingsLoaded;
    emit(BookingActionInProgress(
      actionBookingId: event.id,
      bookings: loaded.bookings,
      totalCount: loaded.totalCount,
      currentFilters: loaded.currentFilters,
      calendarData: loaded.calendarData,
    ));
    final result = await _cancelBooking(
      CancelBookingParams(id: event.id, reason: event.reason),
    );
    result.fold(
      (failure) => emit(ShopBookingsError(failure.message)),
      (updated) {
        final updatedList = loaded.bookings
            .map((b) => b.id == updated.id ? updated : b)
            .toList();
        emit(loaded.copyWith(bookings: updatedList));
      },
    );
  }

  Future<void> _onLoadBookingCalendar(
    LoadBookingCalendar event,
    Emitter<ShopBookingsState> emit,
  ) async {
    final currentLoaded =
        state is ShopBookingsLoaded ? state as ShopBookingsLoaded : null;
    final result = await _getBookingCalendar(CalendarParams(month: event.month));
    result.fold(
      (failure) => emit(ShopBookingsError(failure.message)),
      (calendarData) {
        if (currentLoaded != null) {
          emit(currentLoaded.copyWith(calendarData: calendarData));
        } else {
          emit(ShopBookingsLoaded(
            bookings: const [],
            totalCount: 0,
            currentFilters: BookingFilters.initial(),
            calendarData: calendarData,
          ));
        }
      },
    );
  }
}
