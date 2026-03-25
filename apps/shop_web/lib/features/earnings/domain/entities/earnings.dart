import 'package:equatable/equatable.dart';

/// Earnings entity representing financial summary for a period.
class Earnings extends Equatable {
  const Earnings({
    required this.totalEarnings,
    required this.netEarnings,
    required this.commission,
    required this.tips,
    required this.refunds,
    required this.period,
    required this.startDate,
    required this.endDate,
  });

  final double totalEarnings;
  final double netEarnings;
  final double commission;
  final double tips;
  final double refunds;
  final String period;
  final DateTime startDate;
  final DateTime endDate;

  @override
  List<Object?> get props => [totalEarnings, netEarnings, commission, tips, refunds, period, startDate, endDate];
}
