import '../../domain/entities/referral_reward.dart';

/// Data-layer model for [ReferralReward].
///
/// Extends the domain entity with JSON (de)serialisation and [copyWith].
class ReferralRewardModel extends ReferralReward {
  /// Creates a [ReferralRewardModel].
  const ReferralRewardModel({
    required super.id,
    required super.type,
    required super.amount,
    required super.currency,
    required super.status,
    super.claimedAt,
    super.expiresAt,
  });

  /// Deserialises a [ReferralRewardModel] from a JSON map returned by the API.
  factory ReferralRewardModel.fromJson(Map<String, dynamic> json) {
    return ReferralRewardModel(
      id: json['id'] as String,
      type: RewardTypeX.fromString(json['type'] as String),
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String? ?? 'INR',
      status: RewardStatusX.fromString(json['status'] as String),
      claimedAt: json['claimed_at'] != null
          ? DateTime.parse(json['claimed_at'] as String)
          : null,
      expiresAt: json['expires_at'] != null
          ? DateTime.parse(json['expires_at'] as String)
          : null,
    );
  }

  /// Serialises this model to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.apiValue,
      'amount': amount,
      'currency': currency,
      'status': status.apiValue,
      'claimed_at': claimedAt?.toIso8601String(),
      'expires_at': expiresAt?.toIso8601String(),
    };
  }

  /// Returns a copy of this model with the specified fields replaced.
  ReferralRewardModel copyWith({
    String? id,
    RewardType? type,
    double? amount,
    String? currency,
    RewardStatus? status,
    DateTime? claimedAt,
    DateTime? expiresAt,
  }) {
    return ReferralRewardModel(
      id: id ?? this.id,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      status: status ?? this.status,
      claimedAt: claimedAt ?? this.claimedAt,
      expiresAt: expiresAt ?? this.expiresAt,
    );
  }
}
