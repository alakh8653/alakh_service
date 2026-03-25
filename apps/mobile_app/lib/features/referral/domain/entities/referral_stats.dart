import 'package:equatable/equatable.dart';

/// Domain entity encapsulating aggregated statistics for a user's referral
/// activity.
///
/// Stats are used to render summary cards and tier-progress indicators on the
/// referral hub page.
class ReferralStats extends Equatable {
  /// Total number of referrals initiated by the user (all statuses).
  final int totalReferrals;

  /// Number of referrals currently in a [ReferralStatus.pending] or
  /// [ReferralStatus.registered] state.
  final int pending;

  /// Number of referrals that have reached
  /// [ReferralStatus.firstBookingCompleted] or [ReferralStatus.rewardClaimed].
  final int completed;

  /// Cumulative monetary reward earned (in [currency] units).
  final double totalEarnings;

  /// ISO 4217 currency code, e.g. `"INR"`.
  final String currency;

  /// Name / label of the user's current referral tier, e.g. `"Silver"`.
  final String currentTier;

  /// Number of additional completed referrals required to reach the next tier.
  /// `null` if the user is already at the highest tier.
  final int? nextTierThreshold;

  /// Creates a [ReferralStats] entity.
  const ReferralStats({
    required this.totalReferrals,
    required this.pending,
    required this.completed,
    required this.totalEarnings,
    required this.currency,
    required this.currentTier,
    this.nextTierThreshold,
  });

  /// Progress ratio (0.0 – 1.0) towards the next tier.
  ///
  /// Returns `1.0` when the user is at the highest tier ([nextTierThreshold]
  /// is `null`).
  double get tierProgressRatio {
    if (nextTierThreshold == null || nextTierThreshold! <= 0) return 1.0;
    return (completed / nextTierThreshold!).clamp(0.0, 1.0);
  }

  /// Remaining completed referrals needed to unlock the next tier.
  int get remainingForNextTier {
    if (nextTierThreshold == null) return 0;
    final remaining = nextTierThreshold! - completed;
    return remaining < 0 ? 0 : remaining;
  }

  @override
  List<Object?> get props => [
        totalReferrals,
        pending,
        completed,
        totalEarnings,
        currency,
        currentTier,
        nextTierThreshold,
      ];

  @override
  String toString() =>
      'ReferralStats(total: $totalReferrals, completed: $completed, '
      'earnings: $totalEarnings $currency, tier: $currentTier)';
}
