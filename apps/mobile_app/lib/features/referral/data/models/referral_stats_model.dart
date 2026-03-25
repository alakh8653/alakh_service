import '../../domain/entities/referral_stats.dart';

/// Data-layer model for [ReferralStats].
///
/// Extends the domain entity with JSON (de)serialisation and [copyWith].
class ReferralStatsModel extends ReferralStats {
  /// Creates a [ReferralStatsModel].
  const ReferralStatsModel({
    required super.totalReferrals,
    required super.pending,
    required super.completed,
    required super.totalEarnings,
    required super.currency,
    required super.currentTier,
    super.nextTierThreshold,
  });

  /// Deserialises a [ReferralStatsModel] from a JSON map returned by the API.
  factory ReferralStatsModel.fromJson(Map<String, dynamic> json) {
    return ReferralStatsModel(
      totalReferrals: json['total_referrals'] as int,
      pending: json['pending'] as int,
      completed: json['completed'] as int,
      totalEarnings: (json['total_earnings'] as num).toDouble(),
      currency: json['currency'] as String? ?? 'INR',
      currentTier: json['current_tier'] as String,
      nextTierThreshold: json['next_tier_threshold'] as int?,
    );
  }

  /// Serialises this model to a JSON map for local caching.
  Map<String, dynamic> toJson() {
    return {
      'total_referrals': totalReferrals,
      'pending': pending,
      'completed': completed,
      'total_earnings': totalEarnings,
      'currency': currency,
      'current_tier': currentTier,
      'next_tier_threshold': nextTierThreshold,
    };
  }

  /// Returns a copy of this model with the specified fields replaced.
  ReferralStatsModel copyWith({
    int? totalReferrals,
    int? pending,
    int? completed,
    double? totalEarnings,
    String? currency,
    String? currentTier,
    int? nextTierThreshold,
  }) {
    return ReferralStatsModel(
      totalReferrals: totalReferrals ?? this.totalReferrals,
      pending: pending ?? this.pending,
      completed: completed ?? this.completed,
      totalEarnings: totalEarnings ?? this.totalEarnings,
      currency: currency ?? this.currency,
      currentTier: currentTier ?? this.currentTier,
      nextTierThreshold: nextTierThreshold ?? this.nextTierThreshold,
    );
  }
}
