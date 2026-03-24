import 'package:shop_web/features/earnings/domain/entities/earnings_breakdown.dart';

/// Data model for an earnings breakdown entry returned from the API.
///
/// Each instance represents a single category's contribution to earnings.
class EarningsBreakdownModel {
  /// The name of the category (e.g. "Haircut", "Massage").
  final String category;

  /// Total monetary amount for this category.
  final double amount;

  /// Percentage of total earnings this category represents.
  final double percentage;

  /// Number of transactions contributing to this category.
  final int transactionCount;

  const EarningsBreakdownModel({
    required this.category,
    required this.amount,
    required this.percentage,
    required this.transactionCount,
  });

  /// Creates an [EarningsBreakdownModel] from a JSON map.
  factory EarningsBreakdownModel.fromJson(Map<String, dynamic> json) {
    return EarningsBreakdownModel(
      category: json['category'] as String? ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      percentage: (json['percentage'] as num?)?.toDouble() ?? 0.0,
      transactionCount: (json['transaction_count'] as num?)?.toInt() ?? 0,
    );
  }

  /// Serializes this model to a JSON map.
  Map<String, dynamic> toJson() => {
        'category': category,
        'amount': amount,
        'percentage': percentage,
        'transaction_count': transactionCount,
      };

  /// Converts to the [EarningsBreakdown] domain entity.
  EarningsBreakdown toEntity() => EarningsBreakdown(
        category: category,
        amount: amount,
        percentage: percentage,
        transactionCount: transactionCount,
      );
}
