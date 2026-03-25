import '../../domain/entities/referral_code.dart';

/// Data-layer model for [ReferralCode].
///
/// Extends the domain entity with JSON (de)serialisation and [copyWith].
class ReferralCodeModel extends ReferralCode {
  /// Creates a [ReferralCodeModel].
  const ReferralCodeModel({
    required super.code,
    required super.deepLink,
    super.expiresAt,
    super.maxUses,
    super.usesRemaining,
  });

  /// Deserialises a [ReferralCodeModel] from a JSON map returned by the API.
  factory ReferralCodeModel.fromJson(Map<String, dynamic> json) {
    return ReferralCodeModel(
      code: json['code'] as String,
      deepLink: json['deep_link'] as String,
      expiresAt: json['expires_at'] != null
          ? DateTime.parse(json['expires_at'] as String)
          : null,
      maxUses: json['max_uses'] as int?,
      usesRemaining: json['uses_remaining'] as int?,
    );
  }

  /// Serialises this model to a JSON map for local caching.
  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'deep_link': deepLink,
      'expires_at': expiresAt?.toIso8601String(),
      'max_uses': maxUses,
      'uses_remaining': usesRemaining,
    };
  }

  /// Returns a copy of this model with the specified fields replaced.
  ReferralCodeModel copyWith({
    String? code,
    String? deepLink,
    DateTime? expiresAt,
    int? maxUses,
    int? usesRemaining,
  }) {
    return ReferralCodeModel(
      code: code ?? this.code,
      deepLink: deepLink ?? this.deepLink,
      expiresAt: expiresAt ?? this.expiresAt,
      maxUses: maxUses ?? this.maxUses,
      usesRemaining: usesRemaining ?? this.usesRemaining,
    );
  }
}
