import 'package:dartz/dartz.dart';
import '../entities/entities.dart';
import '../repositories/auth_repository.dart';
import '../../core/failures/failures.dart';

/// Use case for refreshing an expired access token.
class RefreshTokenUseCase {
  final AuthRepository _repository;

  const RefreshTokenUseCase(this._repository);

  /// Executes the token refresh use case.
  ///
  /// Returns a new [AuthToken] on success or a [Failure] on error.
  Future<Either<Failure, AuthToken>> call() {
    return _repository.refreshToken();
  }
}
