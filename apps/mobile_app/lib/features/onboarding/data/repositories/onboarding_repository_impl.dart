import 'package:dartz/dartz.dart';

import '../../domain/entities/entities.dart';
import '../../domain/repositories/onboarding_repository.dart';
import '../datasources/datasources.dart';
import '../models/models.dart';

/// Concrete implementation of [OnboardingRepository].
///
/// Coordinates between [OnboardingRemoteDataSource] (for step definitions)
/// and [OnboardingLocalDataSource] (for completion flag and preferences).
class OnboardingRepositoryImpl implements OnboardingRepository {
  final OnboardingRemoteDataSource _remoteDataSource;
  final OnboardingLocalDataSource _localDataSource;

  const OnboardingRepositoryImpl({
    required OnboardingRemoteDataSource remoteDataSource,
    required OnboardingLocalDataSource localDataSource,
  })  : _remoteDataSource = remoteDataSource,
        _localDataSource = localDataSource;

  @override
  Future<Either<Failure, List<OnboardingStep>>> getOnboardingSteps() async {
    try {
      final steps = await _remoteDataSource.getOnboardingSteps();
      final sorted = [...steps]..sort((a, b) => a.order.compareTo(b.order));
      return Right(sorted);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> isOnboardingCompleted() async {
    try {
      final completed = await _localDataSource.isOnboardingCompleted();
      return Right(completed);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> completeOnboarding() async {
    try {
      await _localDataSource.setOnboardingCompleted();
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> savePreferences(
    UserPreferences preferences,
  ) async {
    try {
      await _localDataSource
          .cachePreferences(UserPreferencesModel.fromEntity(preferences));
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserPreferences>> getPreferences() async {
    try {
      final cached = await _localDataSource.getCachedPreferences();
      if (cached != null) return Right(cached);
      // Return empty default preferences when none are stored yet.
      return const Right(UserPreferences(selectedCategories: []));
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }
}
