import 'package:equatable/equatable.dart';

/// Domain entity representing aggregated financial figures for a time period.
///
/// Used to populate the revenue chart on the Dashboard page.
class RevenueData extends Equatable {
  /// Human-readable label for the time period (e.g. "Jan", "Week 3").
  final String period;

  /// Total revenue collected during this period.
  final double revenue;

  /// Total expenses incurred during this period.
  final double expenses;

  /// Net profit for this period (revenue − expenses).
  final double profit;

  const RevenueData({
    required this.period,
    required this.revenue,
    required this.expenses,
    required this.profit,
  });

  @override
  List<Object?> get props => [period, revenue, expenses, profit];
}
