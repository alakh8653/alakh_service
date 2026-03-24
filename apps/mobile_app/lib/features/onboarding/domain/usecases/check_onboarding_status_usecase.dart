import 'package:dartz/dartz.dart';

import '../repositories/onboarding_repository.dart';

/// Checks whether the current user has already completed onboarding.
class CheckOnboardingStatusUseCase {
  final OnboardingRepository _repository;

  const CheckOnboardingStatusUseCase(this._repository);

  /// Returns `true` when onboarding has been completed, `false` otherwise.
  Future<Either<Failure, bool>> call() => _repository.isOnboardingCompleted();
}
