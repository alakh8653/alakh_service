import 'package:equatable/equatable.dart';

/// Base class for all authentication events.
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Event to check current authentication status on app start.
class AuthCheckRequested extends AuthEvent {
  const AuthCheckRequested();
}

/// Event dispatched when a user attempts to log in.
class LoginRequested extends AuthEvent {
  final String email;
  final String password;

  const LoginRequested({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

/// Event dispatched when a user attempts to register.
class RegisterRequested extends AuthEvent {
  final String name;
  final String email;
  final String phone;
  final String password;

  const RegisterRequested({
    required this.name,
    required this.email,
    required this.phone,
    required this.password,
  });

  @override
  List<Object?> get props => [name, email, phone, password];
}

/// Event dispatched when a user submits an OTP for verification.
class OtpVerifyRequested extends AuthEvent {
  final String phone;
  final String otp;

  const OtpVerifyRequested({required this.phone, required this.otp});

  @override
  List<Object?> get props => [phone, otp];
}

/// Event dispatched when a user requests to log out.
class LogoutRequested extends AuthEvent {
  const LogoutRequested();
}

/// Event dispatched when a user attempts social login.
class SocialLoginRequested extends AuthEvent {
  final String provider;
  final String token;

  const SocialLoginRequested({required this.provider, required this.token});

  @override
  List<Object?> get props => [provider, token];
}

/// Event dispatched to request a token refresh.
class TokenRefreshRequested extends AuthEvent {
  const TokenRefreshRequested();
}
