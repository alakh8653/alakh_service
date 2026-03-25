import 'package:dartz/dartz.dart';
import '../entities/entities.dart';
import '../../core/failures/failures.dart';

/// Parameters for login operation.
class LoginParams {
  final String email;
  final String password;

  const LoginParams({required this.email, required this.password});
}

/// Parameters for registration operation.
class RegisterParams {
  final String name;
  final String email;
  final String phone;
  final String password;

  const RegisterParams({
    required this.name,
    required this.email,
    required this.phone,
    required this.password,
  });
}

/// Parameters for OTP verification.
class OtpParams {
  final String phone;
  final String otp;

  const OtpParams({required this.phone, required this.otp});
}

/// Parameters for social login.
class SocialLoginParams {
  final String provider;
  final String token;

  const SocialLoginParams({required this.provider, required this.token});
}

/// Abstract repository interface for authentication operations.
abstract class AuthRepository {
  /// Logs in a user with email and password.
  Future<Either<Failure, AuthToken>> login(LoginParams params);

  /// Registers a new user.
  Future<Either<Failure, User>> register(RegisterParams params);

  /// Verifies OTP for phone verification.
  Future<Either<Failure, AuthToken>> verifyOtp(OtpParams params);

  /// Logs out the current user and clears local session.
  Future<Either<Failure, Unit>> logout();

  /// Refreshes the access token using the stored refresh token.
  Future<Either<Failure, AuthToken>> refreshToken();

  /// Logs in via a social provider (Google, Facebook, Apple).
  Future<Either<Failure, AuthToken>> socialLogin(SocialLoginParams params);

  /// Retrieves the currently authenticated user profile.
  Future<Either<Failure, User>> getCurrentUser();

  /// Checks whether there is a valid authenticated session.
  Future<Either<Failure, bool>> isAuthenticated();
}
