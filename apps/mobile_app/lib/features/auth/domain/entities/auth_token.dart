import 'package:equatable/equatable.dart';

/// Represents authentication tokens in the domain layer.
class AuthToken extends Equatable {
  /// JWT access token used for API authorization.
  final String accessToken;

  /// Refresh token used to obtain a new access token.
  final String refreshToken;

  /// Expiry timestamp of the access token.
  final DateTime expiresAt;

  const AuthToken({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresAt,
  });

  /// Returns true if the access token has expired.
  bool get isExpired => DateTime.now().isAfter(expiresAt);

  @override
  List<Object?> get props => [accessToken, refreshToken, expiresAt];
}
