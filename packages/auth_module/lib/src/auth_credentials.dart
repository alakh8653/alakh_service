import 'package:equatable/equatable.dart';

/// Base sealed class for all authentication credential types.
sealed class AuthCredentials extends Equatable {
  const AuthCredentials();
}

/// Credentials for email/password authentication.
class EmailCredentials extends AuthCredentials {
  /// The user's email address.
  final String email;

  /// The user's plain-text password (transmitted over TLS, never stored).
  final String password;

  const EmailCredentials({
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [email, password];
}

/// Credentials for phone-number OTP authentication.
class PhoneCredentials extends AuthCredentials {
  /// The user's phone number in E.164 format, e.g. `'+919876543210'`.
  final String phone;

  /// The one-time password received by the user.
  final String otp;

  const PhoneCredentials({
    required this.phone,
    required this.otp,
  });

  @override
  List<Object?> get props => [phone, otp];
}

/// Credentials for social (OAuth) authentication.
class SocialCredentials extends AuthCredentials {
  /// The name of the social provider, e.g. `'google'` or `'apple'`.
  final String provider;

  /// The ID token issued by the social provider.
  final String idToken;

  /// An optional OAuth access token from the social provider.
  final String? accessToken;

  const SocialCredentials({
    required this.provider,
    required this.idToken,
    this.accessToken,
  });

  @override
  List<Object?> get props => [provider, idToken, accessToken];
}
