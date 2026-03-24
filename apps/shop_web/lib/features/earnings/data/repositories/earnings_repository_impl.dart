import 'package:dartz/dartz.dart';
import '../../../../core/errors/shop_error_handler.dart';
import '../../../../core/errors/shop_exceptions.dart';
import '../datasources/earnings_remote_datasource.dart';
import '../../domain/entities/earnings.dart';
import '../../domain/entities/earnings_breakdown.dart';
import '../../domain/repositories/earnings_repository.dart';

/// Implementation of [EarningsRepository].
class EarningsRepositoryImpl implements EarningsRepository {
  EarningsRepositoryImpl(this._dataSource);
  final EarningsRemoteDataSource _dataSource;

  @override
  Future<Either<Failure, Earnings>> getEarnings(DateTime start, DateTime end) async {
    try {
      final model = await _dataSource.getEarnings(start, end);
      return Right(model.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(NetworkFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<EarningsBreakdown>>> getEarningsBreakdown(String period) async {
    try {
      final models = await _dataSource.getEarningsBreakdown(period);
      return Right(models.map((m) => m.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(NetworkFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> comparePeriods(String p1, String p2) async {
    try {
      final data = await _dataSource.comparePeriods(p1, p2);
      return Right(data);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(NetworkFailure(e.toString()));
    }
  }
}
