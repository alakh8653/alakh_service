import 'package:equatable/equatable.dart';

import '../../domain/entities/referral.dart';
import '../../domain/entities/referral_code.dart';
import '../../domain/entities/referral_reward.dart';
import '../../domain/entities/referral_stats.dart';

/// Base class for all referral-related BLoC states.
abstract class ReferralState extends Equatable {
  /// Creates a [ReferralState].
  const ReferralState();

  @override
  List<Object?> get props => [];
}

/// Initial state before any event has been processed.
class ReferralInitial extends ReferralState {
  /// Creates a [ReferralInitial] state.
  const ReferralInitial();
}

/// Emitted while an async operation is in progress.
class ReferralLoading extends ReferralState {
  /// Creates a [ReferralLoading] state.
  const ReferralLoading();
}

/// Emitted after [LoadReferralCode] completes successfully.
class ReferralCodeLoaded extends ReferralState {
  /// The user's referral code.
  final ReferralCode code;

  /// Creates a [ReferralCodeLoaded] state.
  const ReferralCodeLoaded({required this.code});

  @override
  List<Object?> get props => [code];
}

/// Emitted after [LoadReferralStats] completes successfully.
class StatsLoaded extends ReferralState {
  /// The aggregated referral statistics.
  final ReferralStats stats;

  /// Creates a [StatsLoaded] state.
  const StatsLoaded({required this.stats});

  @override
  List<Object?> get props => [stats];
}

/// Emitted after [LoadReferrals] completes successfully.
class ReferralsLoaded extends ReferralState {
  /// Full list of referrals for the user.
  final List<Referral> referrals;

  /// Creates a [ReferralsLoaded] state.
  const ReferralsLoaded({required this.referrals});

  @override
  List<Object?> get props => [referrals];
}

/// Emitted after a [ClaimReward] event completes successfully.
class RewardClaimed extends ReferralState {
  /// The updated reward entity with claimed status.
  final ReferralReward reward;

  /// Creates a [RewardClaimed] state.
  const RewardClaimed({required this.reward});

  @override
  List<Object?> get props => [reward];
}

/// Emitted after an [ApplyCode] event completes successfully.
class CodeApplied extends ReferralState {
  /// Creates a [CodeApplied] state.
  const CodeApplied();
}

/// Emitted after a [ShareReferral] event with the generated share content
/// string ready to pass to the platform share sheet.
class ShareContentReady extends ReferralState {
  /// The shareable text content string.
  final String content;

  /// Creates a [ShareContentReady] state.
  const ShareContentReady({required this.content});

  @override
  List<Object?> get props => [content];
}

/// Emitted after [LoadLeaderboard] completes successfully.
class LeaderboardLoaded extends ReferralState {
  /// List of leaderboard entries; each map contains `rank`, `name`,
  /// `earnings`, and `isCurrentUser`.
  final List<Map<String, dynamic>> entries;

  /// Creates a [LeaderboardLoaded] state.
  const LeaderboardLoaded({required this.entries});

  @override
  List<Object?> get props => [entries];
}

/// Emitted when any referral operation fails.
class ReferralError extends ReferralState {
  /// Human-readable error message for display.
  final String message;

  /// Creates a [ReferralError] state.
  const ReferralError({required this.message});

  @override
  List<Object?> get props => [message];
}
