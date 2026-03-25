import 'package:equatable/equatable.dart';

/// Base class for earnings events.
abstract class EarningsEvent extends Equatable {
  const EarningsEvent();
  @override
  List<Object?> get props => [];
}

/// Load earnings for a date range.
class LoadEarnings extends EarningsEvent {
  const LoadEarnings({required this.startDate, required this.endDate});
  final DateTime startDate;
  final DateTime endDate;
  @override
  List<Object?> get props => [startDate, endDate];
}

/// Load earnings breakdown by period.
class LoadEarningsBreakdown extends EarningsEvent {
  const LoadEarningsBreakdown({required this.period});
  final String period;
  @override
  List<Object?> get props => [period];
}

/// Compare two earnings periods.
class ComparePeriods extends EarningsEvent {
  const ComparePeriods({required this.period1, required this.period2});
  final String period1;
  final String period2;
  @override
  List<Object?> get props => [period1, period2];
}

/// Change selected period filter.
class ChangePeriod extends EarningsEvent {
  const ChangePeriod({required this.period});
  final String period;
  @override
  List<Object?> get props => [period];
}
