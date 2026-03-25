import 'package:dartz/dartz.dart';
import '../repositories/auth_repository.dart';
import '../../core/failures/failures.dart';

/// Use case for checking whether the user is currently authenticated.
class CheckAuthStatusUseCase {
  final AuthRepository _repository;

  const CheckAuthStatusUseCase(this._repository);

  /// Executes the auth status check use case.
  ///
  /// Returns [bool] indicating auth status or a [Failure] on error.
  Future<Either<Failure, bool>> call() {
    return _repository.isAuthenticated();
  }
}
