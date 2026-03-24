import 'package:dartz/dartz.dart';
import 'package:shop_web/core/errors/shop_error_handler.dart';
import 'package:shop_web/core/errors/shop_exceptions.dart';
import 'package:shop_web/features/dashboard/data/datasources/dashboard_remote_datasource.dart';
import 'package:shop_web/features/dashboard/domain/entities/dashboard_summary.dart';
import 'package:shop_web/features/dashboard/domain/entities/recent_activity.dart';
import 'package:shop_web/features/dashboard/domain/entities/revenue_data.dart';
import 'package:shop_web/features/dashboard/domain/repositories/dashboard_repository.dart';

/// Concrete implementation of [DashboardRepository].
///
/// Delegates to [DashboardRemoteDataSource] and maps infrastructure
/// exceptions to typed [Failure] objects so the domain layer stays clean.
class DashboardRepositoryImpl implements DashboardRepository {
  final DashboardRemoteDataSource _remoteDataSource;

  const DashboardRepositoryImpl({
    required DashboardRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  @override
  Future<Either<Failure, DashboardSummary>> getDashboardSummary() async {
    try {
      final model = await _remoteDataSource.getDashboardSummary();
      return Right(model.toEntity());
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<RevenueData>>> getRevenueChart(
    DateTime start,
    DateTime end,
  ) async {
    try {
      final models = await _remoteDataSource.getRevenueChart(start, end);
      return Right(models.map((m) => m.toEntity()).toList());
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<RecentActivity>>> getRecentActivity(
      int limit) async {
    try {
      final models = await _remoteDataSource.getRecentActivity(limit);
      return Right(models.map((m) => m.toEntity()).toList());
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
