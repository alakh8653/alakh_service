import 'package:equatable/equatable.dart';

/// Represents an authentication token pair with access and refresh tokens.
class AuthToken extends Equatable {
  /// The short-lived access token used to authenticate API requests.
  final String accessToken;

  /// The long-lived refresh token used to obtain new access tokens.
  final String refreshToken;

  /// The UTC date/time at which [accessToken] expires.
  final DateTime expiresAt;

  /// The token scheme, typically `'Bearer'`.
  final String tokenType;

  const AuthToken({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresAt,
    this.tokenType = 'Bearer',
  });

  /// Returns `true` if the access token has already expired.
  bool get isExpired => DateTime.now().isAfter(expiresAt);

  /// Returns `true` if the access token will expire within the next 5 minutes.
  bool get isAboutToExpire =>
      DateTime.now().isAfter(expiresAt.subtract(const Duration(minutes: 5)));

  /// Returns the formatted Authorization header value, e.g. `'Bearer <token>'`.
  String get authHeader => '$tokenType $accessToken';

  /// Deserialises an [AuthToken] from a JSON map.
  ///
  /// Expected keys: `access_token`, `refresh_token`, `expires_at`,
  /// optionally `token_type`.
  factory AuthToken.fromJson(Map<String, dynamic> json) {
    return AuthToken(
      accessToken: json['access_token'] as String,
      refreshToken: json['refresh_token'] as String,
      expiresAt: DateTime.parse(json['expires_at'] as String),
      tokenType: (json['token_type'] as String?) ?? 'Bearer',
    );
  }

  /// Serialises this token to a JSON map.
  Map<String, dynamic> toJson() => {
        'access_token': accessToken,
        'refresh_token': refreshToken,
        'expires_at': expiresAt.toIso8601String(),
        'token_type': tokenType,
      };

  /// Returns a copy of this token with the given fields replaced.
  AuthToken copyWith({
    String? accessToken,
    String? refreshToken,
    DateTime? expiresAt,
    String? tokenType,
  }) {
    return AuthToken(
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      expiresAt: expiresAt ?? this.expiresAt,
      tokenType: tokenType ?? this.tokenType,
    );
  }

  @override
  List<Object?> get props => [accessToken, refreshToken, expiresAt, tokenType];
}
