import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/shop_error_handler.dart';
import '../entities/earnings_breakdown.dart';
import '../repositories/earnings_repository.dart';

/// Use case to fetch earnings breakdown by period.
class GetEarningsBreakdownUseCase implements UseCase<List<EarningsBreakdown>, PeriodParams> {
  GetEarningsBreakdownUseCase(this._repository);
  final EarningsRepository _repository;

  @override
  Future<Either<Failure, List<EarningsBreakdown>>> call(PeriodParams params) =>
      _repository.getEarningsBreakdown(params.period);
}

class PeriodParams extends Equatable {
  const PeriodParams({required this.period});
  final String period;
  @override
  List<Object?> get props => [period];
}
