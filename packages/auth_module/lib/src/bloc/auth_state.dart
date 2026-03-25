import 'package:flutter/foundation.dart';
import 'package:shared_models/shared_models.dart';

@immutable
sealed class AuthState {}

final class AuthInitial extends AuthState {}

final class AuthLoading extends AuthState {}

final class Authenticated extends AuthState {
  Authenticated({required this.user});
  final UserModel user;
}

final class Unauthenticated extends AuthState {}

final class AuthError extends AuthState {
  AuthError({required this.message});
  final String message;
}
