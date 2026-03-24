import 'package:dartz/dartz.dart';
import '../entities/entities.dart';
import '../repositories/auth_repository.dart';
import '../../core/failures/failures.dart';

/// Use case for verifying a one-time password (OTP).
class VerifyOtpUseCase {
  final AuthRepository _repository;

  const VerifyOtpUseCase(this._repository);

  /// Executes the OTP verification use case.
  ///
  /// Returns [AuthToken] on success or a [Failure] on error.
  Future<Either<Failure, AuthToken>> call(OtpParams params) {
    return _repository.verifyOtp(params);
  }
}
