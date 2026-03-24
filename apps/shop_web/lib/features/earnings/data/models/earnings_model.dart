import 'package:shop_web/features/earnings/domain/entities/earnings.dart';

/// Data model for earnings summary returned from the API.
///
/// Handles JSON serialization and converts to the [Earnings] domain entity.
class EarningsModel {
  /// Gross total earnings before deductions.
  final double totalEarnings;

  /// Net earnings after commission, tips and refunds.
  final double netEarnings;

  /// Platform commission deducted.
  final double commission;

  /// Tips collected during the period.
  final double tips;

  /// Total refunds issued during the period.
  final double refunds;

  /// Human-readable period label (e.g. "weekly", "monthly").
  final String period;

  /// Start of the reporting period.
  final DateTime startDate;

  /// End of the reporting period.
  final DateTime endDate;

  const EarningsModel({
    required this.totalEarnings,
    required this.netEarnings,
    required this.commission,
    required this.tips,
    required this.refunds,
    required this.period,
    required this.startDate,
    required this.endDate,
  });

  /// Creates an [EarningsModel] from a JSON map.
  factory EarningsModel.fromJson(Map<String, dynamic> json) {
    return EarningsModel(
      totalEarnings: (json['total_earnings'] as num?)?.toDouble() ?? 0.0,
      netEarnings: (json['net_earnings'] as num?)?.toDouble() ?? 0.0,
      commission: (json['commission'] as num?)?.toDouble() ?? 0.0,
      tips: (json['tips'] as num?)?.toDouble() ?? 0.0,
      refunds: (json['refunds'] as num?)?.toDouble() ?? 0.0,
      period: json['period'] as String? ?? '',
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: DateTime.parse(json['end_date'] as String),
    );
  }

  /// Serializes this model to a JSON map.
  Map<String, dynamic> toJson() => {
        'total_earnings': totalEarnings,
        'net_earnings': netEarnings,
        'commission': commission,
        'tips': tips,
        'refunds': refunds,
        'period': period,
        'start_date': startDate.toIso8601String(),
        'end_date': endDate.toIso8601String(),
      };

  /// Converts to the [Earnings] domain entity.
  Earnings toEntity() => Earnings(
        totalEarnings: totalEarnings,
        netEarnings: netEarnings,
        commission: commission,
        tips: tips,
        refunds: refunds,
        period: period,
        startDate: startDate,
        endDate: endDate,
      );
}
