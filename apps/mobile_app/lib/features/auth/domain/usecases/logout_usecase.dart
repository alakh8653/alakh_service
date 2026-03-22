import 'package:dartz/dartz.dart';
import '../repositories/auth_repository.dart';
import '../../core/failures/failures.dart';

/// Use case for logging out the current user.
class LogoutUseCase {
  final AuthRepository _repository;

  const LogoutUseCase(this._repository);

  /// Executes the logout use case.
  ///
  /// Returns [Unit] on success or a [Failure] on error.
  Future<Either<Failure, Unit>> call() {
    return _repository.logout();
  }
}
