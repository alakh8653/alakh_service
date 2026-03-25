import 'package:equatable/equatable.dart';

/// Base class for all Dashboard BLoC events.
abstract class DashboardEvent extends Equatable {
  const DashboardEvent();

  @override
  List<Object?> get props => [];
}

/// Triggers a full dashboard load (summary + chart + activity).
///
/// Dispatched on initial page load.
class LoadDashboard extends DashboardEvent {
  const LoadDashboard();
}

/// Triggers a revenue chart reload for the specified date range.
class LoadRevenueChart extends DashboardEvent {
  /// Start of the requested date range (inclusive).
  final DateTime startDate;

  /// End of the requested date range (inclusive).
  final DateTime endDate;

  const LoadRevenueChart({required this.startDate, required this.endDate});

  @override
  List<Object?> get props => [startDate, endDate];
}

/// Triggers a reload of the recent activity feed.
class LoadRecentActivity extends DashboardEvent {
  /// Maximum number of activity events to fetch.
  final int limit;

  const LoadRecentActivity({required this.limit});

  @override
  List<Object?> get props => [limit];
}

/// Refreshes the entire dashboard (identical behaviour to [LoadDashboard]).
///
/// Kept as a separate event so the UI can distinguish pull-to-refresh
/// from initial load if needed.
class RefreshDashboard extends DashboardEvent {
  const RefreshDashboard();
}
