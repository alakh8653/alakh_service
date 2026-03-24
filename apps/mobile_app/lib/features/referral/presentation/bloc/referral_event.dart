import 'package:equatable/equatable.dart';

import '../../domain/entities/referral_code.dart';

/// Base class for all referral-related BLoC events.
abstract class ReferralEvent extends Equatable {
  /// Creates a [ReferralEvent].
  const ReferralEvent();

  @override
  List<Object?> get props => [];
}

/// Dispatched when the user opens the referral hub and requires their personal
/// referral code.
class LoadReferralCode extends ReferralEvent {
  /// Creates a [LoadReferralCode] event.
  const LoadReferralCode();
}

/// Dispatched when aggregated referral statistics are needed (e.g. on the
/// stats or hub page).
class LoadReferralStats extends ReferralEvent {
  /// Creates a [LoadReferralStats] event.
  const LoadReferralStats();
}

/// Dispatched to load the full list of referrals.
class LoadReferrals extends ReferralEvent {
  /// Creates a [LoadReferrals] event.
  const LoadReferrals();
}

/// Dispatched when the user taps the "Claim" button on a reward card.
class ClaimReward extends ReferralEvent {
  /// Identifier of the reward to claim.
  final String rewardId;

  /// Creates a [ClaimReward] event.
  const ClaimReward({required this.rewardId});

  @override
  List<Object?> get props => [rewardId];
}

/// Dispatched when the user submits a referral code they received from a
/// friend.
class ApplyCode extends ReferralEvent {
  /// The raw referral code string entered by the user.
  final String code;

  /// Creates an [ApplyCode] event.
  const ApplyCode({required this.code});

  @override
  List<Object?> get props => [code];
}

/// Dispatched when the user taps a share action (share sheet, WhatsApp, etc.).
class ShareReferral extends ReferralEvent {
  /// The user's referral code to generate share content from.
  final ReferralCode referralCode;

  /// Creates a [ShareReferral] event.
  const ShareReferral({required this.referralCode});

  @override
  List<Object?> get props => [referralCode];
}

/// Dispatched when the leaderboard page is opened or refreshed.
class LoadLeaderboard extends ReferralEvent {
  /// Creates a [LoadLeaderboard] event.
  const LoadLeaderboard();
}
