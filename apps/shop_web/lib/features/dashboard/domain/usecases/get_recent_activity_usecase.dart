import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:shop_web/core/errors/shop_error_handler.dart';
import 'package:shop_web/features/dashboard/domain/entities/recent_activity.dart';
import 'package:shop_web/features/dashboard/domain/repositories/dashboard_repository.dart';

/// Parameters required by [GetRecentActivityUseCase].
class RecentActivityParams extends Equatable {
  /// Maximum number of activity events to return.
  final int limit;

  const RecentActivityParams({required this.limit});

  @override
  List<Object?> get props => [limit];
}

/// Use case that retrieves the most-recent [RecentActivity] events.
class GetRecentActivityUseCase
    extends UseCase<List<RecentActivity>, RecentActivityParams> {
  final DashboardRepository _repository;

  const GetRecentActivityUseCase({required DashboardRepository repository})
      : _repository = repository;

  /// Executes the use case with the supplied [RecentActivityParams].
  @override
  Future<Either<Failure, List<RecentActivity>>> call(
      RecentActivityParams params) {
    return _repository.getRecentActivity(params.limit);
  }
}
