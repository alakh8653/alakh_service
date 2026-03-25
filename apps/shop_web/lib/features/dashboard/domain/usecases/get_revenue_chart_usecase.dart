import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:shop_web/core/errors/shop_error_handler.dart';
import 'package:shop_web/features/dashboard/domain/entities/revenue_data.dart';
import 'package:shop_web/features/dashboard/domain/repositories/dashboard_repository.dart';

/// Parameters required by [GetRevenueChartUseCase].
class RevenueChartParams extends Equatable {
  /// Inclusive start of the requested date range.
  final DateTime startDate;

  /// Inclusive end of the requested date range.
  final DateTime endDate;

  const RevenueChartParams({required this.startDate, required this.endDate});

  @override
  List<Object?> get props => [startDate, endDate];
}

/// Use case that retrieves aggregated [RevenueData] for a date range.
class GetRevenueChartUseCase
    extends UseCase<List<RevenueData>, RevenueChartParams> {
  final DashboardRepository _repository;

  const GetRevenueChartUseCase({required DashboardRepository repository})
      : _repository = repository;

  /// Executes the use case with the supplied [RevenueChartParams].
  @override
  Future<Either<Failure, List<RevenueData>>> call(
      RevenueChartParams params) {
    return _repository.getRevenueChart(params.startDate, params.endDate);
  }
}
