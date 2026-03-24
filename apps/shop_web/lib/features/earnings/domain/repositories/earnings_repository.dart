import 'package:dartz/dartz.dart';
import '../../../../core/errors/shop_error_handler.dart';
import '../entities/earnings.dart';
import '../entities/earnings_breakdown.dart';

/// Abstract repository for earnings operations.
abstract class EarningsRepository {
  Future<Either<Failure, Earnings>> getEarnings(DateTime start, DateTime end);
  Future<Either<Failure, List<EarningsBreakdown>>> getEarningsBreakdown(String period);
  Future<Either<Failure, Map<String, dynamic>>> comparePeriods(String p1, String p2);
}
