import 'package:dartz/dartz.dart';
import 'package:shop_web/core/errors/shop_error_handler.dart';
import 'package:shop_web/features/dashboard/domain/entities/dashboard_summary.dart';
import 'package:shop_web/features/dashboard/domain/entities/recent_activity.dart';
import 'package:shop_web/features/dashboard/domain/entities/revenue_data.dart';

/// Contract for the dashboard data layer.
///
/// Implementations must handle all infrastructure concerns (network, cache)
/// and surface domain-level [Failure]s through the [Left] channel.
abstract class DashboardRepository {
  /// Returns the high-level [DashboardSummary] KPIs for today.
  Future<Either<Failure, DashboardSummary>> getDashboardSummary();

  /// Returns a list of [RevenueData] points for the given date range.
  ///
  /// [start] and [end] are treated as inclusive boundaries.
  Future<Either<Failure, List<RevenueData>>> getRevenueChart(
    DateTime start,
    DateTime end,
  );

  /// Returns the [limit] most-recent [RecentActivity] events.
  Future<Either<Failure, List<RecentActivity>>> getRecentActivity(int limit);
}
