import 'package:dartz/dartz.dart';
import '../entities/entities.dart';
import '../repositories/auth_repository.dart';
import '../../core/failures/failures.dart';

/// Use case for logging in a user with email and password.
class LoginUseCase {
  final AuthRepository _repository;

  const LoginUseCase(this._repository);

  /// Executes the login use case.
  ///
  /// Returns [AuthToken] on success or a [Failure] on error.
  Future<Either<Failure, AuthToken>> call(LoginParams params) {
    return _repository.login(params);
  }
}
