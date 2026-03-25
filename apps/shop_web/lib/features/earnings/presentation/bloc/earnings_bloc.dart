import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_earnings_usecase.dart';
import '../../domain/usecases/get_earnings_breakdown_usecase.dart';
import '../../domain/usecases/compare_periods_usecase.dart';
import 'earnings_event.dart';
import 'earnings_state.dart';

/// BLoC for earnings management.
class EarningsBloc extends Bloc<EarningsEvent, EarningsState> {
  EarningsBloc({
    required GetEarningsUseCase getEarnings,
    required GetEarningsBreakdownUseCase getBreakdown,
    required ComparePeriodsUseCase comparePeriods,
  })  : _getEarnings = getEarnings,
        _getBreakdown = getBreakdown,
        _comparePeriods = comparePeriods,
        super(const EarningsInitial()) {
    on<LoadEarnings>(_onLoadEarnings);
    on<LoadEarningsBreakdown>(_onLoadBreakdown);
    on<ComparePeriods>(_onComparePeriods);
    on<ChangePeriod>(_onChangePeriod);
  }

  final GetEarningsUseCase _getEarnings;
  final GetEarningsBreakdownUseCase _getBreakdown;
  final ComparePeriodsUseCase _comparePeriods;

  Future<void> _onLoadEarnings(LoadEarnings event, Emitter<EarningsState> emit) async {
    emit(const EarningsLoading());
    final earningsResult = await _getEarnings(EarningsParams(startDate: event.startDate, endDate: event.endDate));
    await earningsResult.fold(
      (failure) async => emit(EarningsError(message: failure.message)),
      (earnings) async {
        final breakdownResult = await _getBreakdown(const PeriodParams(period: 'monthly'));
        breakdownResult.fold(
          (f) => emit(EarningsLoaded(earnings: earnings, breakdown: const [])),
          (breakdown) => emit(EarningsLoaded(earnings: earnings, breakdown: breakdown)),
        );
      },
    );
  }

  Future<void> _onLoadBreakdown(LoadEarningsBreakdown event, Emitter<EarningsState> emit) async {
    final result = await _getBreakdown(PeriodParams(period: event.period));
    if (state is EarningsLoaded) {
      result.fold(
        (f) => null,
        (breakdown) => emit((state as EarningsLoaded).copyWith(breakdown: breakdown)),
      );
    }
  }

  Future<void> _onComparePeriods(ComparePeriods event, Emitter<EarningsState> emit) async {
    final result = await _comparePeriods(CompareParams(period1: event.period1, period2: event.period2));
    if (state is EarningsLoaded) {
      result.fold(
        (f) => null,
        (comparison) => emit((state as EarningsLoaded).copyWith(comparison: comparison)),
      );
    }
  }

  void _onChangePeriod(ChangePeriod event, Emitter<EarningsState> emit) {
    if (state is EarningsLoaded) {
      emit((state as EarningsLoaded).copyWith(selectedPeriod: event.period));
    }
  }
}
