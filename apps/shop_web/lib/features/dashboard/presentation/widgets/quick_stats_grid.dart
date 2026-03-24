import 'package:flutter/material.dart';
import 'package:shop_web/features/dashboard/domain/entities/dashboard_summary.dart';
import 'package:shop_web/shared/shared.dart';

/// Responsive grid of [StatCard] widgets displaying the key KPIs from
/// [DashboardSummary].
///
/// Uses a [Wrap] layout so the cards re-flow gracefully across breakpoints
/// without any media-query boilerplate in this widget.
class QuickStatsGrid extends StatelessWidget {
  final DashboardSummary summary;

  const QuickStatsGrid({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    final cards = [
      _StatCardConfig(
        title: "Today's Revenue",
        value: '₹${summary.todayRevenue.toStringAsFixed(2)}',
        icon: Icons.currency_rupee_rounded,
        color: Colors.green,
        change: summary.revenueChange,
        isPercentage: true,
      ),
      _StatCardConfig(
        title: 'Total Bookings',
        value: summary.totalBookings.toString(),
        icon: Icons.calendar_today_rounded,
        color: Colors.blue,
        change: summary.bookingsChange.toDouble(),
        isPercentage: false,
      ),
      _StatCardConfig(
        title: 'Active Queue',
        value: summary.activeQueue.toString(),
        icon: Icons.people_alt_rounded,
        color: Colors.orange,
      ),
      _StatCardConfig(
        title: 'Avg Rating',
        value: summary.avgRating.toStringAsFixed(1),
        icon: Icons.star_rounded,
        color: Colors.amber,
      ),
      _StatCardConfig(
        title: 'Pending Actions',
        value: summary.pendingActions.toString(),
        icon: Icons.pending_actions_rounded,
        color: Colors.red,
      ),
    ];

    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: cards.map((cfg) {
        return SizedBox(
          width: 200,
          child: StatCard(
            title: cfg.title,
            value: cfg.value,
            icon: cfg.icon,
            iconColor: cfg.color,
            trend: cfg.change != null
                ? '${cfg.change! >= 0 ? '+' : ''}${cfg.isPercentage ? '${cfg.change!.toStringAsFixed(1)}%' : cfg.change!.toStringAsFixed(0)}'
                : null,
            trendPositive: cfg.change == null || cfg.change! >= 0,
          ),
        );
      }).toList(),
    );
  }
}

/// Internal configuration object for each stat card.
class _StatCardConfig {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final double? change;
  final bool isPercentage;

  const _StatCardConfig({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.change,
    this.isPercentage = false,
  });
}
