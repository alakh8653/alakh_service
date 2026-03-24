import 'package:dartz/dartz.dart';

import '../datasources/datasources.dart';
import '../models/models.dart';
import '../../core/failures.dart';
import '../../domain/entities/entities.dart';
import '../../domain/repositories/booking_repository.dart';

/// Concrete implementation of [BookingRepository] that coordinates remote and
/// local data sources with error handling.
class BookingRepositoryImpl implements BookingRepository {
  final BookingRemoteDataSource _remote;
  final BookingLocalDataSource _local;

  const BookingRepositoryImpl({
    required BookingRemoteDataSource remote,
    required BookingLocalDataSource local,
  })  : _remote = remote,
        _local = local;

  @override
  Future<Either<Failure, Booking>> createBooking(CreateBookingParams params) async {
    try {
      final request = BookingRequestModel(
        userId: params.userId,
        shopId: params.shopId,
        serviceId: params.serviceId,
        timeSlotId: params.timeSlotId,
        staffId: params.staffId,
        notes: params.notes,
      );
      final model = await _remote.createBooking(request);
      await _local.cacheBookingDetails(model);
      return Right(model);
    } on Exception catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Booking>> cancelBooking(String bookingId, String reason) async {
    try {
      final model = await _remote.cancelBooking(bookingId, reason);
      await _local.cacheBookingDetails(model);
      return Right(model);
    } on Exception catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Booking>> rescheduleBooking(RescheduleParams params) async {
    try {
      final model = await _remote.rescheduleBooking(
        params.bookingId,
        params.newTimeSlotId,
        params.reason,
      );
      await _local.cacheBookingDetails(model);
      return Right(model);
    } on Exception catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<TimeSlot>>> getAvailableSlots(SlotsParams params) async {
    try {
      final slots = await _remote.getAvailableSlots(
        params.shopId,
        params.serviceId,
        params.date,
        params.staffId,
      );
      return Right(slots);
    } on Exception catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Booking>>> getUserBookings(String userId) async {
    try {
      final models = await _remote.getUserBookings(userId);
      await _local.cacheBookings(models);
      return Right(models);
    } on Exception catch (_) {
      try {
        final cached = await _local.getCachedBookings();
        if (cached.isNotEmpty) return Right(cached);
        return const Left(CacheFailure('No cached bookings available'));
      } on Exception catch (e) {
        return Left(CacheFailure(e.toString()));
      }
    }
  }

  @override
  Future<Either<Failure, Booking>> getBookingDetails(String bookingId) async {
    try {
      final model = await _remote.getBookingDetails(bookingId);
      await _local.cacheBookingDetails(model);
      return Right(model);
    } on Exception catch (_) {
      try {
        final cached = await _local.getCachedBookingDetails(bookingId);
        if (cached != null) return Right(cached);
        return const Left(CacheFailure('Booking details not found in cache'));
      } on Exception catch (e) {
        return Left(CacheFailure(e.toString()));
      }
    }
  }

  @override
  Future<Either<Failure, List<Booking>>> getUpcomingBookings(String userId) async {
    try {
      final models = await _remote.getUpcomingBookings(userId);
      return Right(models);
    } on Exception catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
