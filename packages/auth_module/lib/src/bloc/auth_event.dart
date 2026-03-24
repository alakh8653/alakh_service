import 'package:flutter/foundation.dart';

@immutable
sealed class AuthEvent {}

final class AuthCheckStatus extends AuthEvent {}

final class AuthLoginRequested extends AuthEvent {
  AuthLoginRequested({required this.email, required this.password});
  final String email;
  final String password;
}

final class AuthRegisterRequested extends AuthEvent {
  AuthRegisterRequested({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.password,
    this.phone,
  });
  final String firstName;
  final String lastName;
  final String email;
  final String password;
  final String? phone;
}

final class AuthLogoutRequested extends AuthEvent {}

final class AuthTokenRefreshed extends AuthEvent {}
