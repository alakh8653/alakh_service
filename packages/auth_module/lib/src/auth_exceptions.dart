/// Base sealed class for all authentication-related exceptions.
sealed class AuthException implements Exception {
  /// A human-readable description of the error.
  final String message;

  const AuthException(this.message);

  @override
  String toString() => '$runtimeType: $message';
}

/// Thrown when the supplied credentials are incorrect.
class InvalidCredentialsException extends AuthException {
  const InvalidCredentialsException([
    String message = 'The provided credentials are invalid.',
  ]) : super(message);
}

/// Thrown when the access token has expired and no refresh was attempted.
class TokenExpiredException extends AuthException {
  const TokenExpiredException([
    String message = 'The authentication token has expired.',
  ]) : super(message);
}

/// Thrown when attempting to refresh a token fails.
class TokenRefreshFailedException extends AuthException {
  const TokenRefreshFailedException([
    String message = 'Failed to refresh the authentication token.',
  ]) : super(message);
}

/// Thrown when the account is temporarily locked.
class AccountLockedException extends AuthException {
  /// The date/time at which the account lock is lifted, if known.
  final DateTime? unlockedAt;

  const AccountLockedException({
    String message = 'The account is locked.',
    this.unlockedAt,
  }) : super(message);
}

/// Thrown when the account has not been verified (e.g. email/phone not confirmed).
class AccountNotVerifiedException extends AuthException {
  const AccountNotVerifiedException([
    String message = 'The account has not been verified.',
  ]) : super(message);
}

/// Thrown when no account matching the provided identifier is found.
class AccountNotFoundException extends AuthException {
  const AccountNotFoundException([
    String message = 'No account was found with the provided identifier.',
  ]) : super(message);
}

/// Thrown when the user's session has expired and re-authentication is required.
class SessionExpiredException extends AuthException {
  const SessionExpiredException([
    String message = 'The session has expired. Please sign in again.',
  ]) : super(message);
}

/// Thrown when biometric authentication fails or is unavailable.
class BiometricAuthException extends AuthException {
  const BiometricAuthException([
    String message = 'Biometric authentication failed.',
  ]) : super(message);
}

/// Thrown when social (OAuth) sign-in fails.
class SocialAuthException extends AuthException {
  /// The name of the social provider that failed, e.g. `'google'`.
  final String provider;

  const SocialAuthException({
    required this.provider,
    String message = 'Social authentication failed.',
  }) : super(message);
}

/// Thrown when the OTP has expired before verification.
class OtpExpiredException extends AuthException {
  const OtpExpiredException([
    String message = 'The OTP has expired.',
  ]) : super(message);
}

/// Thrown when the supplied OTP does not match the expected value.
class OtpInvalidException extends AuthException {
  const OtpInvalidException([
    String message = 'The OTP is invalid.',
  ]) : super(message);
}

/// Thrown when the OTP request limit has been exceeded.
class OtpLimitExceededException extends AuthException {
  const OtpLimitExceededException([
    String message = 'Too many OTP requests. Please try again later.',
  ]) : super(message);
}
