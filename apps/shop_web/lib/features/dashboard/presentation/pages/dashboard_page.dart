import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shop_web/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:shop_web/features/dashboard/presentation/bloc/dashboard_event.dart';
import 'package:shop_web/features/dashboard/presentation/bloc/dashboard_state.dart';
import 'package:shop_web/features/dashboard/presentation/widgets/activity_feed.dart';
import 'package:shop_web/features/dashboard/presentation/widgets/quick_actions.dart';
import 'package:shop_web/features/dashboard/presentation/widgets/quick_stats_grid.dart';
import 'package:shop_web/features/dashboard/presentation/widgets/recent_bookings_table.dart';
import 'package:shop_web/features/dashboard/presentation/widgets/revenue_chart.dart';
import 'package:shop_web/shared/shared.dart';

/// Main Dashboard page of the Shop Web application.
///
/// Dispatches [LoadDashboard] on mount and builds its layout reactively via
/// [BlocBuilder]. Shows a shimmer skeleton during load, an error card on
/// failure, and the full dashboard on success.
///
/// Layout (desktop):
/// ```
/// ┌──────────────────────────────────────────┐
/// │  PageHeader – "Dashboard"                │
/// ├──────────────────────────────────────────┤
/// │  QuickStatsGrid (5 KPI cards)            │
/// ├─────────────────────────┬────────────────┤
/// │  RevenueChart (2/3)     │ ActivityFeed   │
/// │                         │ (1/3)          │
/// ├─────────────────────────┴────────────────┤
/// │  RecentBookingsTable (2/3) │ QuickActions│
/// └──────────────────────────────────────────┘
/// ```
class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  @override
  void initState() {
    super.initState();
    context.read<DashboardBloc>().add(const LoadDashboard());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardBloc, DashboardState>(
      builder: (context, state) {
        if (state is DashboardLoading || state is DashboardInitial) {
          return const _DashboardSkeleton();
        }
        if (state is DashboardError) {
          return _DashboardErrorView(
            message: state.message,
            onRetry: () =>
                context.read<DashboardBloc>().add(const RefreshDashboard()),
          );
        }
        if (state is DashboardLoaded) {
          return _DashboardContent(state: state);
        }
        return const SizedBox.shrink();
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Loaded content
// ---------------------------------------------------------------------------

class _DashboardContent extends StatelessWidget {
  final DashboardLoaded state;

  const _DashboardContent({required this.state});

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 960;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PageHeader(
            title: 'Dashboard',
            actions: [
              ExportButton(onPressed: () {}),
            ],
          ),
          const SizedBox(height: 24),

          // KPI row
          QuickStatsGrid(summary: state.summary),
          const SizedBox(height: 24),

          // Revenue chart + activity feed
          isWide
              ? _WideRow(
                  left: RevenueChart(
                    data: state.revenueData,
                    onPeriodChanged: (range) {
                      context.read<DashboardBloc>().add(
                            LoadRevenueChart(
                              startDate: range.start,
                              endDate: range.end,
                            ),
                          );
                    },
                  ),
                  leftFlex: 2,
                  right: ActivityFeed(activities: state.recentActivity),
                  rightFlex: 1,
                )
              : Column(children: [
                  RevenueChart(
                    data: state.revenueData,
                    onPeriodChanged: (range) {
                      context.read<DashboardBloc>().add(
                            LoadRevenueChart(
                              startDate: range.start,
                              endDate: range.end,
                            ),
                          );
                    },
                  ),
                  const SizedBox(height: 16),
                  ActivityFeed(activities: state.recentActivity),
                ]),
          const SizedBox(height: 24),

          // Recent bookings + quick actions
          isWide
              ? _WideRow(
                  left: RecentBookingsTable(
                      activities: state.recentActivity),
                  leftFlex: 2,
                  right: const QuickActions(),
                  rightFlex: 1,
                )
              : Column(children: [
                  RecentBookingsTable(activities: state.recentActivity),
                  const SizedBox(height: 16),
                  const QuickActions(),
                ]),
        ],
      ),
    );
  }
}

/// Lays out two children side-by-side with configurable flex ratios.
class _WideRow extends StatelessWidget {
  final Widget left;
  final int leftFlex;
  final Widget right;
  final int rightFlex;

  const _WideRow({
    required this.left,
    required this.leftFlex,
    required this.right,
    required this.rightFlex,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: leftFlex, child: left),
        const SizedBox(width: 16),
        Expanded(flex: rightFlex, child: right),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Skeleton / loading state
// ---------------------------------------------------------------------------

class _DashboardSkeleton extends StatelessWidget {
  const _DashboardSkeleton();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _shimmerBox(height: 40, width: 200),
          const SizedBox(height: 24),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: List.generate(
              5,
              (_) => _shimmerBox(height: 100, width: 200),
            ),
          ),
          const SizedBox(height: 24),
          Row(children: [
            Expanded(flex: 2, child: _shimmerBox(height: 300)),
            const SizedBox(width: 16),
            Expanded(child: _shimmerBox(height: 300)),
          ]),
          const SizedBox(height: 24),
          _shimmerBox(height: 240),
        ],
      ),
    );
  }

  Widget _shimmerBox({double? height, double? width}) {
    return LoadingTable(height: height ?? 100, width: width);
  }
}

// ---------------------------------------------------------------------------
// Error state
// ---------------------------------------------------------------------------

class _DashboardErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _DashboardErrorView({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Something went wrong',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
