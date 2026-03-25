import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shop_web/core/errors/shop_error_handler.dart';
import 'package:shop_web/features/dashboard/domain/entities/dashboard_summary.dart';
import 'package:shop_web/features/dashboard/domain/entities/recent_activity.dart';
import 'package:shop_web/features/dashboard/domain/entities/revenue_data.dart';
import 'package:shop_web/features/dashboard/domain/usecases/get_dashboard_summary_usecase.dart';
import 'package:shop_web/features/dashboard/domain/usecases/get_recent_activity_usecase.dart';
import 'package:shop_web/features/dashboard/domain/usecases/get_revenue_chart_usecase.dart';
import 'package:shop_web/features/dashboard/presentation/bloc/dashboard_event.dart';
import 'package:shop_web/features/dashboard/presentation/bloc/dashboard_state.dart';

/// BLoC that orchestrates all data loading for the Dashboard page.
class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final GetDashboardSummaryUseCase _getDashboardSummary;
  final GetRevenueChartUseCase _getRevenueChart;
  final GetRecentActivityUseCase _getRecentActivity;

  /// Default date range used for the initial revenue chart load (30 days).
  static final DateTime _defaultEnd = DateTime.now();
  static final DateTime _defaultStart =
      _defaultEnd.subtract(const Duration(days: 30));

  DashboardBloc({
    required GetDashboardSummaryUseCase getDashboardSummary,
    required GetRevenueChartUseCase getRevenueChart,
    required GetRecentActivityUseCase getRecentActivity,
  })  : _getDashboardSummary = getDashboardSummary,
        _getRevenueChart = getRevenueChart,
        _getRecentActivity = getRecentActivity,
        super(const DashboardInitial()) {
    on<LoadDashboard>(_onLoadDashboard);
    on<RefreshDashboard>(_onRefreshDashboard);
    on<LoadRevenueChart>(_onLoadRevenueChart);
    on<LoadRecentActivity>(_onLoadRecentActivity);
  }

  Future<void> _onLoadDashboard(
    LoadDashboard event,
    Emitter<DashboardState> emit,
  ) async {
    emit(const DashboardLoading());
    await _loadAll(emit, _defaultStart, _defaultEnd);
  }

  Future<void> _onRefreshDashboard(
    RefreshDashboard event,
    Emitter<DashboardState> emit,
  ) async {
    emit(const DashboardLoading());
    await _loadAll(emit, _defaultStart, _defaultEnd);
  }

  Future<void> _onLoadRevenueChart(
    LoadRevenueChart event,
    Emitter<DashboardState> emit,
  ) async {
    if (state is DashboardLoaded) {
      final current = state as DashboardLoaded;
      emit(RevenueChartLoading(
        summary: current.summary,
        revenueData: current.revenueData,
        recentActivity: current.recentActivity,
      ));
      final result = await _getRevenueChart(
        RevenueChartParams(startDate: event.startDate, endDate: event.endDate),
      );
      result.fold(
        (failure) => emit(DashboardError(message: failure.message)),
        (data) => emit(current.copyWith(revenueData: data)),
      );
    }
  }

  Future<void> _onLoadRecentActivity(
    LoadRecentActivity event,
    Emitter<DashboardState> emit,
  ) async {
    if (state is DashboardLoaded) {
      final current = state as DashboardLoaded;
      final result = await _getRecentActivity(
        RecentActivityParams(limit: event.limit),
      );
      result.fold(
        (failure) => emit(DashboardError(message: failure.message)),
        (data) => emit(current.copyWith(recentActivity: data)),
      );
    }
  }

  /// Fetches all three data sets concurrently and emits a unified state.
  Future<void> _loadAll(
    Emitter<DashboardState> emit,
    DateTime start,
    DateTime end,
  ) async {
    final results = await Future.wait([
      _getDashboardSummary(const NoParams()),
      _getRevenueChart(RevenueChartParams(startDate: start, endDate: end)),
      _getRecentActivity(const RecentActivityParams(limit: 20)),
    ]);

    final summaryResult = results[0];
    final revenueResult = results[1];
    final activityResult = results[2];

    // Surface the first failure encountered.
    for (final r in results) {
      if (r.isLeft()) {
        final failure = r.fold((f) => f, (_) => null) as Failure;
        emit(DashboardError(message: failure.message));
        return;
      }
    }

    emit(DashboardLoaded(
      summary: summaryResult.getOrElse(() => const DashboardSummary(
            todayRevenue: 0,
            totalBookings: 0,
            activeQueue: 0,
            avgRating: 0,
            pendingActions: 0,
            revenueChange: 0,
            bookingsChange: 0,
          )) as DashboardSummary,
      revenueData: revenueResult.getOrElse(() => <RevenueData>[])
          as List<RevenueData>,
      recentActivity: activityResult.getOrElse(() => <RecentActivity>[])
          as List<RecentActivity>,
    ));
  }
}
