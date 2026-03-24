import 'package:dartz/dartz.dart';
import '../entities/entities.dart';
import '../repositories/auth_repository.dart';
import '../../core/failures/failures.dart';

/// Use case for fetching the currently authenticated user.
class GetCurrentUserUseCase {
  final AuthRepository _repository;

  const GetCurrentUserUseCase(this._repository);

  /// Executes the get current user use case.
  ///
  /// Returns [User] on success or a [Failure] on error.
  Future<Either<Failure, User>> call() {
    return _repository.getCurrentUser();
  }
}
