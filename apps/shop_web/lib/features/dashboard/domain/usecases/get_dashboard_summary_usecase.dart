import 'package:dartz/dartz.dart';
import 'package:shop_web/core/errors/shop_error_handler.dart';
import 'package:shop_web/features/dashboard/domain/entities/dashboard_summary.dart';
import 'package:shop_web/features/dashboard/domain/repositories/dashboard_repository.dart';

/// Use case that retrieves the high-level [DashboardSummary] KPIs.
///
/// Accepts [NoParams] as it fetches the summary for the current day
/// without any caller-supplied parameters.
class GetDashboardSummaryUseCase extends UseCase<DashboardSummary, NoParams> {
  final DashboardRepository _repository;

  const GetDashboardSummaryUseCase({required DashboardRepository repository})
      : _repository = repository;

  /// Executes the use case, forwarding the result from [DashboardRepository].
  @override
  Future<Either<Failure, DashboardSummary>> call(NoParams params) {
    return _repository.getDashboardSummary();
  }
}
