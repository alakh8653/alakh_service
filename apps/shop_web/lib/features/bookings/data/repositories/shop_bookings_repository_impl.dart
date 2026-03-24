/// Concrete implementation of [ShopBookingsRepository].
library;

import 'package:dartz/dartz.dart';
import 'package:shop_web/core/errors/shop_error_handler.dart';
import 'package:shop_web/core/errors/shop_exceptions.dart';
import 'package:shop_web/features/bookings/data/datasources/shop_bookings_remote_datasource.dart';
import 'package:shop_web/features/bookings/data/models/booking_filter_model.dart';
import 'package:shop_web/features/bookings/domain/entities/booking_filters.dart';
import 'package:shop_web/features/bookings/domain/entities/shop_booking.dart';
import 'package:shop_web/features/bookings/domain/repositories/shop_bookings_repository.dart';

/// Bridges the data and domain layers for all booking operations.
class ShopBookingsRepositoryImpl implements ShopBookingsRepository {
  const ShopBookingsRepositoryImpl({
    required ShopBookingsRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  final ShopBookingsRemoteDataSource _remoteDataSource;

  @override
  Future<Either<Failure, (List<ShopBooking>, int)>> getBookings(
    BookingFilters filters,
  ) async {
    try {
      final filterModel = _toFilterModel(filters);
      final (models, total) = await _remoteDataSource.getBookings(filterModel);
      return Right((models.map((m) => m.toEntity()).toList(), total));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, ShopBooking>> getBookingById(String id) async {
    try {
      final model = await _remoteDataSource.getBookingById(id);
      return Right(model.toEntity());
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, ShopBooking>> updateBookingStatus(
    String id,
    String status,
  ) async {
    try {
      final model = await _remoteDataSource.updateBookingStatus(id, status);
      return Right(model.toEntity());
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, ShopBooking>> cancelBooking(
    String id,
    String reason,
  ) async {
    try {
      final model = await _remoteDataSource.cancelBooking(id, reason);
      return Right(model.toEntity());
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<DateTime, List<ShopBooking>>>> getBookingCalendar(
    DateTime month,
  ) async {
    try {
      final raw = await _remoteDataSource.getBookingCalendar(month);
      final result = raw.map(
        (date, models) =>
            MapEntry(date, models.map((m) => m.toEntity()).toList()),
      );
      return Right(result);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  /// Converts a domain [BookingFilters] entity to the data-layer model.
  BookingFilterModel _toFilterModel(BookingFilters filters) {
    return BookingFilterModel(
      status: filters.status,
      dateRange: filters.dateRange,
      staffId: filters.staffId,
      searchQuery: filters.searchQuery,
      page: filters.page,
      pageSize: filters.pageSize,
      sortBy: filters.sortBy,
      sortAsc: filters.sortAsc,
    );
  }
}
