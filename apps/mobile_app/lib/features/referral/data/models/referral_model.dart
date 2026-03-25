import '../../domain/entities/referral.dart';
import '../../domain/entities/referral_status.dart';

/// Data-layer model for [Referral].
///
/// Extends the domain entity with JSON (de)serialisation and [copyWith].
class ReferralModel extends Referral {
  /// Creates a [ReferralModel].
  const ReferralModel({
    required super.id,
    required super.referrerId,
    required super.refereeId,
    required super.refereeName,
    required super.code,
    required super.status,
    required super.rewardAmount,
    required super.currency,
    required super.createdAt,
    super.completedAt,
  });

  /// Deserialises a [ReferralModel] from a JSON map returned by the API.
  factory ReferralModel.fromJson(Map<String, dynamic> json) {
    return ReferralModel(
      id: json['id'] as String,
      referrerId: json['referrer_id'] as String,
      refereeId: json['referee_id'] as String,
      refereeName: json['referee_name'] as String,
      code: json['code'] as String,
      status: ReferralStatusX.fromString(json['status'] as String),
      rewardAmount: (json['reward_amount'] as num).toDouble(),
      currency: json['currency'] as String? ?? 'INR',
      createdAt: DateTime.parse(json['created_at'] as String),
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'] as String)
          : null,
    );
  }

  /// Serialises this model to a JSON map for API requests or local storage.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'referrer_id': referrerId,
      'referee_id': refereeId,
      'referee_name': refereeName,
      'code': code,
      'status': status.apiValue,
      'reward_amount': rewardAmount,
      'currency': currency,
      'created_at': createdAt.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
    };
  }

  /// Returns a copy of this model with the specified fields replaced.
  ReferralModel copyWith({
    String? id,
    String? referrerId,
    String? refereeId,
    String? refereeName,
    String? code,
    ReferralStatus? status,
    double? rewardAmount,
    String? currency,
    DateTime? createdAt,
    DateTime? completedAt,
  }) {
    return ReferralModel(
      id: id ?? this.id,
      referrerId: referrerId ?? this.referrerId,
      refereeId: refereeId ?? this.refereeId,
      refereeName: refereeName ?? this.refereeName,
      code: code ?? this.code,
      status: status ?? this.status,
      rewardAmount: rewardAmount ?? this.rewardAmount,
      currency: currency ?? this.currency,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}
