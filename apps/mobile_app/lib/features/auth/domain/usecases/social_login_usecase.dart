import 'package:dartz/dartz.dart';
import '../entities/entities.dart';
import '../repositories/auth_repository.dart';
import '../../core/failures/failures.dart';

/// Use case for social login (Google, Facebook, Apple).
class SocialLoginUseCase {
  final AuthRepository _repository;

  const SocialLoginUseCase(this._repository);

  /// Executes the social login use case.
  ///
  /// Returns [AuthToken] on success or a [Failure] on error.
  Future<Either<Failure, AuthToken>> call(SocialLoginParams params) {
    return _repository.socialLogin(params);
  }
}
