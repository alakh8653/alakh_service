import 'package:shop_web/features/dashboard/domain/entities/revenue_data.dart';

/// Data model for a single revenue data point returned from the API.
///
/// Represents aggregated financial figures for a given time period and
/// maps directly to the [RevenueData] domain entity.
class RevenueDataModel {
  /// The label for this time period (e.g. "Jan", "Week 3", "2024-05-01").
  final String period;

  /// Total revenue collected during this period.
  final double revenue;

  /// Total expenses incurred during this period.
  final double expenses;

  /// Net profit for this period (revenue − expenses).
  final double profit;

  const RevenueDataModel({
    required this.period,
    required this.revenue,
    required this.expenses,
    required this.profit,
  });

  /// Creates a [RevenueDataModel] from a JSON map.
  factory RevenueDataModel.fromJson(Map<String, dynamic> json) {
    return RevenueDataModel(
      period: (json['period'] as String?) ?? '',
      revenue: (json['revenue'] as num?)?.toDouble() ?? 0.0,
      expenses: (json['expenses'] as num?)?.toDouble() ?? 0.0,
      profit: (json['profit'] as num?)?.toDouble() ?? 0.0,
    );
  }

  /// Serializes this model to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'period': period,
      'revenue': revenue,
      'expenses': expenses,
      'profit': profit,
    };
  }

  /// Converts this model to the [RevenueData] domain entity.
  RevenueData toEntity() {
    return RevenueData(
      period: period,
      revenue: revenue,
      expenses: expenses,
      profit: profit,
    );
  }
}
