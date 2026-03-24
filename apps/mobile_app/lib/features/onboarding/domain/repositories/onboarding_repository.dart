import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../entities/entities.dart';

// ── Failure hierarchy ─────────────────────────────────────────────────────────

/// Base failure class used across the onboarding domain.
abstract class Failure extends Equatable {
  final String message;
  const Failure(this.message);

  @override
  List<Object> get props => [message];
}

/// Failure originating from a remote server call.
class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

/// Failure originating from local cache / storage.
class CacheFailure extends Failure {
  const CacheFailure(super.message);
}

// ── Repository interface ──────────────────────────────────────────────────────

/// Abstract contract for all onboarding data operations.
abstract class OnboardingRepository {
  /// Fetches the ordered list of onboarding steps.
  Future<Either<Failure, List<OnboardingStep>>> getOnboardingSteps();

  /// Returns `true` if the user has already completed onboarding.
  Future<Either<Failure, bool>> isOnboardingCompleted();

  /// Marks onboarding as completed for the current user.
  Future<Either<Failure, void>> completeOnboarding();

  /// Persists the given [preferences] for the current user.
  Future<Either<Failure, void>> savePreferences(UserPreferences preferences);

  /// Retrieves the previously saved user preferences.
  Future<Either<Failure, UserPreferences>> getPreferences();
}
