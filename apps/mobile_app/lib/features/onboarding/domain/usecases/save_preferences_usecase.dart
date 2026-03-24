import 'package:dartz/dartz.dart';

import '../entities/entities.dart';
import '../repositories/onboarding_repository.dart';

/// Persists the user-selected [UserPreferences].
class SavePreferencesUseCase {
  final OnboardingRepository _repository;

  const SavePreferencesUseCase(this._repository);

  /// Executes the use case with the provided [preferences].
  Future<Either<Failure, void>> call(UserPreferences preferences) =>
      _repository.savePreferences(preferences);
}
