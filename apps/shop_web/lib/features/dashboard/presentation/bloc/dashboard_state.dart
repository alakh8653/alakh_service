import 'package:equatable/equatable.dart';
import 'package:shop_web/features/dashboard/domain/entities/dashboard_summary.dart';
import 'package:shop_web/features/dashboard/domain/entities/recent_activity.dart';
import 'package:shop_web/features/dashboard/domain/entities/revenue_data.dart';

/// Base class for all Dashboard BLoC states.
abstract class DashboardState extends Equatable {
  const DashboardState();

  @override
  List<Object?> get props => [];
}

/// The bloc has not yet started loading.
class DashboardInitial extends DashboardState {
  const DashboardInitial();
}

/// A full-screen loading indicator should be shown.
class DashboardLoading extends DashboardState {
  const DashboardLoading();
}

/// All data has been loaded successfully.
class DashboardLoaded extends DashboardState {
  final DashboardSummary summary;
  final List<RevenueData> revenueData;
  final List<RecentActivity> recentActivity;

  const DashboardLoaded({
    required this.summary,
    required this.revenueData,
    required this.recentActivity,
  });

  /// Returns a copy of this state with optional field overrides.
  DashboardLoaded copyWith({
    DashboardSummary? summary,
    List<RevenueData>? revenueData,
    List<RecentActivity>? recentActivity,
  }) {
    return DashboardLoaded(
      summary: summary ?? this.summary,
      revenueData: revenueData ?? this.revenueData,
      recentActivity: recentActivity ?? this.recentActivity,
    );
  }

  @override
  List<Object?> get props => [summary, revenueData, recentActivity];
}

/// A non-blocking loading state for the revenue chart.
///
/// Extends [DashboardLoaded] so existing KPI cards remain visible while
/// the chart refreshes in the background.
class RevenueChartLoading extends DashboardLoaded {
  const RevenueChartLoading({
    required super.summary,
    required super.revenueData,
    required super.recentActivity,
  });

  @override
  List<Object?> get props => [...super.props, 'chart_loading'];
}

/// An unrecoverable error occurred during a dashboard data load.
class DashboardError extends DashboardState {
  /// Human-readable description of the error.
  final String message;

  const DashboardError({required this.message});

  @override
  List<Object?> get props => [message];
}
