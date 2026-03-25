import 'package:dartz/dartz.dart';

import '../repositories/onboarding_repository.dart';

/// Marks onboarding as finished for the current user.
class CompleteOnboardingUseCase {
  final OnboardingRepository _repository;

  const CompleteOnboardingUseCase(this._repository);

  /// Executes the use case.
  Future<Either<Failure, void>> call() => _repository.completeOnboarding();
}
