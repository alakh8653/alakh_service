import 'package:equatable/equatable.dart';

/// Earnings breakdown entity for a single category.
class EarningsBreakdown extends Equatable {
  const EarningsBreakdown({
    required this.category,
    required this.amount,
    required this.percentage,
    required this.transactionCount,
  });

  final String category;
  final double amount;
  final double percentage;
  final int transactionCount;

  @override
  List<Object?> get props => [category, amount, percentage, transactionCount];
}
