import 'package:dartz/dartz.dart';
import '../entities/entities.dart';
import '../repositories/auth_repository.dart';
import '../../core/failures/failures.dart';

/// Use case for registering a new user.
class RegisterUseCase {
  final AuthRepository _repository;

  const RegisterUseCase(this._repository);

  /// Executes the register use case.
  ///
  /// Returns [User] on success or a [Failure] on error.
  Future<Either<Failure, User>> call(RegisterParams params) {
    return _repository.register(params);
  }
}
