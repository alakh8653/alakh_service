import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repositories/booking_repository.dart';
import '../../domain/usecases/usecases.dart';
import 'booking_event.dart';
import 'booking_state.dart';

/// BLoC that orchestrates all booking-related events and states.
class BookingBloc extends Bloc<BookingEvent, BookingState> {
  final GetAvailableSlotsUseCase _getAvailableSlots;
  final CreateBookingUseCase _createBooking;
  final CancelBookingUseCase _cancelBooking;
  final RescheduleBookingUseCase _rescheduleBooking;
  final GetUserBookingsUseCase _getUserBookings;
  final GetBookingDetailsUseCase _getBookingDetails;
  final GetUpcomingBookingsUseCase _getUpcomingBookings;

  BookingBloc({
    required GetAvailableSlotsUseCase getAvailableSlots,
    required CreateBookingUseCase createBooking,
    required CancelBookingUseCase cancelBooking,
    required RescheduleBookingUseCase rescheduleBooking,
    required GetUserBookingsUseCase getUserBookings,
    required GetBookingDetailsUseCase getBookingDetails,
    required GetUpcomingBookingsUseCase getUpcomingBookings,
  })  : _getAvailableSlots = getAvailableSlots,
        _createBooking = createBooking,
        _cancelBooking = cancelBooking,
        _rescheduleBooking = rescheduleBooking,
        _getUserBookings = getUserBookings,
        _getBookingDetails = getBookingDetails,
        _getUpcomingBookings = getUpcomingBookings,
        super(const BookingInitial()) {
    on<LoadSlots>(_onLoadSlots);
    on<CreateBooking>(_onCreateBooking);
    on<CancelBooking>(_onCancelBooking);
    on<RescheduleBooking>(_onRescheduleBooking);
    on<LoadUserBookings>(_onLoadUserBookings);
    on<LoadBookingDetails>(_onLoadBookingDetails);
    on<LoadUpcomingBookings>(_onLoadUpcomingBookings);
  }

  Future<void> _onLoadSlots(LoadSlots event, Emitter<BookingState> emit) async {
    emit(const SlotsLoading());
    final result = await _getAvailableSlots(SlotsParams(
      shopId: event.shopId,
      serviceId: event.serviceId,
      date: event.date,
      staffId: event.staffId,
    ));
    result.fold(
      (failure) => emit(BookingError(failure.message)),
      (slots) => emit(SlotsLoaded(slots: slots, selectedDate: event.date)),
    );
  }

  Future<void> _onCreateBooking(CreateBooking event, Emitter<BookingState> emit) async {
    emit(const BookingCreating());
    final result = await _createBooking(event.params);
    result.fold(
      (failure) => emit(BookingError(failure.message)),
      (booking) => emit(BookingCreated(booking)),
    );
  }

  Future<void> _onCancelBooking(CancelBooking event, Emitter<BookingState> emit) async {
    final result = await _cancelBooking(
      CancelBookingParams(bookingId: event.bookingId, reason: event.reason),
    );
    result.fold(
      (failure) => emit(BookingError(failure.message)),
      (booking) => emit(BookingCancelled(booking)),
    );
  }

  Future<void> _onRescheduleBooking(
      RescheduleBooking event, Emitter<BookingState> emit) async {
    final result = await _rescheduleBooking(event.params);
    result.fold(
      (failure) => emit(BookingError(failure.message)),
      (booking) => emit(BookingRescheduled(booking)),
    );
  }

  Future<void> _onLoadUserBookings(
      LoadUserBookings event, Emitter<BookingState> emit) async {
    emit(const SlotsLoading());
    final result = await _getUserBookings(event.userId);
    result.fold(
      (failure) => emit(BookingError(failure.message)),
      (bookings) => emit(BookingsLoaded(bookings)),
    );
  }

  Future<void> _onLoadBookingDetails(
      LoadBookingDetails event, Emitter<BookingState> emit) async {
    final result = await _getBookingDetails(event.bookingId);
    result.fold(
      (failure) => emit(BookingError(failure.message)),
      (booking) => emit(BookingDetailsLoaded(booking)),
    );
  }

  Future<void> _onLoadUpcomingBookings(
      LoadUpcomingBookings event, Emitter<BookingState> emit) async {
    final result = await _getUpcomingBookings(event.userId);
    result.fold(
      (failure) => emit(BookingError(failure.message)),
      (bookings) => emit(UpcomingBookingsLoaded(bookings)),
    );
  }
}
