import 'package:dartz/dartz.dart';

import '../entities/entities.dart';
import '../repositories/onboarding_repository.dart';

/// Returns the ordered list of [OnboardingStep]s to display.
class GetOnboardingStepsUseCase {
  final OnboardingRepository _repository;

  const GetOnboardingStepsUseCase(this._repository);

  /// Executes the use case.
  Future<Either<Failure, List<OnboardingStep>>> call() =>
      _repository.getOnboardingSteps();
}
