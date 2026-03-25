import 'package:equatable/equatable.dart';
import '../../domain/entities/entities.dart';

/// Base class for all authentication states.
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// Initial state before any auth check has been performed.
class AuthInitial extends AuthState {
  const AuthInitial();
}

/// State indicating an authentication operation is in progress.
class AuthLoading extends AuthState {
  const AuthLoading();
}

/// State indicating the user is authenticated.
class Authenticated extends AuthState {
  final User user;
  final AuthToken token;

  const Authenticated({required this.user, required this.token});

  @override
  List<Object?> get props => [user, token];
}

/// State indicating the user is not authenticated.
class Unauthenticated extends AuthState {
  const Unauthenticated();
}

/// State indicating an authentication error occurred.
class AuthError extends AuthState {
  final String message;

  const AuthError({required this.message});

  @override
  List<Object?> get props => [message];
}

/// State indicating OTP has been sent and awaiting verification.
class OtpSent extends AuthState {
  final String phone;

  const OtpSent({required this.phone});

  @override
  List<Object?> get props => [phone];
}

/// State indicating OTP has been successfully verified.
class OtpVerified extends AuthState {
  final AuthToken token;

  const OtpVerified({required this.token});

  @override
  List<Object?> get props => [token];
}
