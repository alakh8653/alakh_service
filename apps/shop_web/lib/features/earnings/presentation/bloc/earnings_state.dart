import 'package:equatable/equatable.dart';
import '../../domain/entities/earnings.dart';
import '../../domain/entities/earnings_breakdown.dart';

/// Base class for earnings states.
abstract class EarningsState extends Equatable {
  const EarningsState();
  @override
  List<Object?> get props => [];
}

/// Initial state.
class EarningsInitial extends EarningsState {
  const EarningsInitial();
}

/// Loading earnings data.
class EarningsLoading extends EarningsState {
  const EarningsLoading();
}

/// Earnings data loaded successfully.
class EarningsLoaded extends EarningsState {
  const EarningsLoaded({
    required this.earnings,
    required this.breakdown,
    this.comparison,
    this.selectedPeriod = 'monthly',
  });

  final Earnings earnings;
  final List<EarningsBreakdown> breakdown;
  final Map<String, dynamic>? comparison;
  final String selectedPeriod;

  EarningsLoaded copyWith({
    Earnings? earnings,
    List<EarningsBreakdown>? breakdown,
    Map<String, dynamic>? comparison,
    String? selectedPeriod,
  }) => EarningsLoaded(
    earnings: earnings ?? this.earnings,
    breakdown: breakdown ?? this.breakdown,
    comparison: comparison ?? this.comparison,
    selectedPeriod: selectedPeriod ?? this.selectedPeriod,
  );

  @override
  List<Object?> get props => [earnings, breakdown, comparison, selectedPeriod];
}

/// Error loading earnings.
class EarningsError extends EarningsState {
  const EarningsError({required this.message});
  final String message;
  @override
  List<Object?> get props => [message];
}
