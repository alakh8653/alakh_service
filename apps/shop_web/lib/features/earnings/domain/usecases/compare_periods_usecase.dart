import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/shop_error_handler.dart';
import '../repositories/earnings_repository.dart';

/// Use case to compare two earnings periods.
class ComparePeriodsUseCase implements UseCase<Map<String, dynamic>, CompareParams> {
  ComparePeriodsUseCase(this._repository);
  final EarningsRepository _repository;

  @override
  Future<Either<Failure, Map<String, dynamic>>> call(CompareParams params) =>
      _repository.comparePeriods(params.period1, params.period2);
}

class CompareParams extends Equatable {
  const CompareParams({required this.period1, required this.period2});
  final String period1;
  final String period2;
  @override
  List<Object?> get props => [period1, period2];
}
