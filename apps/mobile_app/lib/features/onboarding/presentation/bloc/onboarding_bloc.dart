import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/entities.dart';
import '../../domain/usecases/usecases.dart';

part 'onboarding_event.dart';
part 'onboarding_state.dart';

/// BLoC that orchestrates the entire onboarding flow.
class OnboardingBloc extends Bloc<OnboardingEvent, OnboardingState> {
  final GetOnboardingStepsUseCase _getOnboardingSteps;
  final CompleteOnboardingUseCase _completeOnboarding;
  final SavePreferencesUseCase _savePreferences;
  final CheckOnboardingStatusUseCase _checkOnboardingStatus;

  OnboardingBloc({
    required GetOnboardingStepsUseCase getOnboardingSteps,
    required CompleteOnboardingUseCase completeOnboarding,
    required SavePreferencesUseCase savePreferences,
    required CheckOnboardingStatusUseCase checkOnboardingStatus,
  })  : _getOnboardingSteps = getOnboardingSteps,
        _completeOnboarding = completeOnboarding,
        _savePreferences = savePreferences,
        _checkOnboardingStatus = checkOnboardingStatus,
        super(const OnboardingInitial()) {
    on<CheckOnboardingStatus>(_onCheckOnboardingStatus);
    on<LoadOnboardingSteps>(_onLoadOnboardingSteps);
    on<NextStep>(_onNextStep);
    on<PreviousStep>(_onPreviousStep);
    on<SkipOnboarding>(_onSkipOnboarding);
    on<CompleteOnboarding>(_onCompleteOnboarding);
    on<SavePreferences>(_onSavePreferences);
  }

  Future<void> _onCheckOnboardingStatus(
    CheckOnboardingStatus event,
    Emitter<OnboardingState> emit,
  ) async {
    emit(const OnboardingLoading());
    final result = await _checkOnboardingStatus();
    result.fold(
      (failure) => emit(OnboardingError(failure.message)),
      (completed) {
        if (completed) {
          emit(const OnboardingCompleted());
        } else {
          emit(const OnboardingInitial());
        }
      },
    );
  }

  Future<void> _onLoadOnboardingSteps(
    LoadOnboardingSteps event,
    Emitter<OnboardingState> emit,
  ) async {
    emit(const OnboardingLoading());
    final result = await _getOnboardingSteps();
    result.fold(
      (failure) => emit(OnboardingError(failure.message)),
      (steps) => emit(
        OnboardingInProgress(steps: steps, currentIndex: 0),
      ),
    );
  }

  void _onNextStep(NextStep event, Emitter<OnboardingState> emit) {
    final current = state;
    if (current is! OnboardingInProgress) return;

    if (current.isLastStep) {
      add(const CompleteOnboarding());
    } else {
      emit(
        OnboardingInProgress(
          steps: current.steps,
          currentIndex: current.currentIndex + 1,
        ),
      );
    }
  }

  void _onPreviousStep(PreviousStep event, Emitter<OnboardingState> emit) {
    final current = state;
    if (current is! OnboardingInProgress || current.isFirstStep) return;

    emit(
      OnboardingInProgress(
        steps: current.steps,
        currentIndex: current.currentIndex - 1,
      ),
    );
  }

  Future<void> _onSkipOnboarding(
    SkipOnboarding event,
    Emitter<OnboardingState> emit,
  ) async {
    emit(const OnboardingLoading());
    final result = await _completeOnboarding();
    result.fold(
      (failure) => emit(OnboardingError(failure.message)),
      (_) => emit(const OnboardingCompleted()),
    );
  }

  Future<void> _onCompleteOnboarding(
    CompleteOnboarding event,
    Emitter<OnboardingState> emit,
  ) async {
    final result = await _completeOnboarding();
    result.fold(
      (failure) => emit(OnboardingError(failure.message)),
      (_) => emit(const OnboardingCompleted()),
    );
  }

  Future<void> _onSavePreferences(
    SavePreferences event,
    Emitter<OnboardingState> emit,
  ) async {
    final result = await _savePreferences(event.preferences);
    result.fold(
      (failure) => emit(OnboardingError(failure.message)),
      (_) => add(const NextStep()),
    );
  }
}
