part of 'onboarding_bloc.dart';

/// Base class for all onboarding BLoC events.
abstract class OnboardingEvent extends Equatable {
  const OnboardingEvent();

  @override
  List<Object?> get props => [];
}

/// Triggers fetching and displaying the onboarding steps.
class LoadOnboardingSteps extends OnboardingEvent {
  const LoadOnboardingSteps();
}

/// Advances the flow to the next step.
class NextStep extends OnboardingEvent {
  const NextStep();
}

/// Returns to the previous step.
class PreviousStep extends OnboardingEvent {
  const PreviousStep();
}

/// Skips directly to the end of the onboarding flow.
class SkipOnboarding extends OnboardingEvent {
  const SkipOnboarding();
}

/// Marks onboarding as completed and persists the flag.
class CompleteOnboarding extends OnboardingEvent {
  const CompleteOnboarding();
}

/// Saves the supplied [preferences] and advances the flow.
class SavePreferences extends OnboardingEvent {
  final UserPreferences preferences;

  const SavePreferences(this.preferences);

  @override
  List<Object?> get props => [preferences];
}

/// Checks whether the user has already completed onboarding.
class CheckOnboardingStatus extends OnboardingEvent {
  const CheckOnboardingStatus();
}
