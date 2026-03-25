import 'package:equatable/equatable.dart';

import 'auth_exceptions.dart';
import 'auth_token.dart';

/// Base sealed class representing the authentication lifecycle state.
sealed class AuthState extends Equatable {
  const AuthState();
}

/// Initial state before any authentication check has been performed.
class AuthInitial extends AuthState {
  const AuthInitial();

  @override
  List<Object?> get props => [];
}

/// State while an authentication operation (login, logout, refresh) is in
/// progress.
class AuthLoading extends AuthState {
  const AuthLoading();

  @override
  List<Object?> get props => [];
}

/// State indicating that the user is authenticated.
class Authenticated extends AuthState {
  /// The unique identifier of the authenticated user.
  final String userId;

  /// The user's email address, if available.
  final String? email;

  /// The user's phone number, if available.
  final String? phone;

  /// The current authentication token pair.
  final AuthToken token;

  const Authenticated({
    required this.userId,
    required this.token,
    this.email,
    this.phone,
  });

  /// Returns a copy with the given fields replaced.
  Authenticated copyWith({
    String? userId,
    String? email,
    String? phone,
    AuthToken? token,
  }) {
    return Authenticated(
      userId: userId ?? this.userId,
      token: token ?? this.token,
      email: email ?? this.email,
      phone: phone ?? this.phone,
    );
  }

  @override
  List<Object?> get props => [userId, email, phone, token];
}

/// State indicating that no user is authenticated.
class Unauthenticated extends AuthState {
  const Unauthenticated();

  @override
  List<Object?> get props => [];
}

/// State indicating that an authentication operation failed.
class AuthError extends AuthState {
  /// The exception that caused the error.
  final AuthException error;

  const AuthError(this.error);

  @override
  List<Object?> get props => [error];
}
