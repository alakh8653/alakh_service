import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/shop_error_handler.dart';
import '../entities/earnings.dart';
import '../repositories/earnings_repository.dart';

/// Use case to fetch earnings for a date range.
class GetEarningsUseCase implements UseCase<Earnings, EarningsParams> {
  GetEarningsUseCase(this._repository);
  final EarningsRepository _repository;

  @override
  Future<Either<Failure, Earnings>> call(EarningsParams params) =>
      _repository.getEarnings(params.startDate, params.endDate);
}

/// Parameters for [GetEarningsUseCase].
class EarningsParams extends Equatable {
  const EarningsParams({required this.startDate, required this.endDate});
  final DateTime startDate;
  final DateTime endDate;
  @override
  List<Object?> get props => [startDate, endDate];
}
