part of 'onboarding_bloc.dart';

/// Base class for all onboarding BLoC states.
abstract class OnboardingState extends Equatable {
  const OnboardingState();

  @override
  List<Object?> get props => [];
}

/// The initial state before any action has been dispatched.
class OnboardingInitial extends OnboardingState {
  const OnboardingInitial();
}

/// An async operation is in progress.
class OnboardingLoading extends OnboardingState {
  const OnboardingLoading();
}

/// Onboarding steps have been loaded and the user is progressing through them.
class OnboardingInProgress extends OnboardingState {
  /// All onboarding steps to display.
  final List<OnboardingStep> steps;

  /// Zero-based index of the currently visible step.
  final int currentIndex;

  const OnboardingInProgress({
    required this.steps,
    required this.currentIndex,
  });

  /// Whether the current step is the last one.
  bool get isLastStep => currentIndex == steps.length - 1;

  /// Whether the current step is the first one.
  bool get isFirstStep => currentIndex == 0;

  @override
  List<Object?> get props => [steps, currentIndex];
}

/// All onboarding steps have been completed (or skipped).
class OnboardingCompleted extends OnboardingState {
  const OnboardingCompleted();
}

/// An error occurred during any onboarding operation.
class OnboardingError extends OnboardingState {
  /// Human-readable description of the error.
  final String message;

  const OnboardingError(this.message);

  @override
  List<Object?> get props => [message];
}
