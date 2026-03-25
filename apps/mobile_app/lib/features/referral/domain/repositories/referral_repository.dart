import 'package:dartz/dartz.dart';
import 'package:mobile_app/core/error/failures.dart';

import '../entities/referral.dart';
import '../entities/referral_code.dart';
import '../entities/referral_reward.dart';
import '../entities/referral_stats.dart';

/// Contract that data-layer implementations must fulfil for all referral
/// operations.
///
/// Every method returns an [Either] so that callers can handle [Failure] cases
/// without relying on exceptions.
abstract class ReferralRepository {
  /// Fetches the authenticated user's unique referral code from the backend,
  /// falling back to a local cache when the device is offline.
  Future<Either<Failure, ReferralCode>> getReferralCode();

  /// Fetches aggregated statistics for the authenticated user's referral
  /// activity.
  Future<Either<Failure, ReferralStats>> getReferralStats();

  /// Fetches the full list of referrals initiated by the authenticated user.
  ///
  /// The list is ordered by [Referral.createdAt] descending (most recent
  /// first).
  Future<Either<Failure, List<Referral>>> getReferrals();

  /// Submits a claim for the reward identified by [rewardId].
  ///
  /// Returns the updated [ReferralReward] entity with
  /// [RewardStatus.claimed] status on success.
  Future<Either<Failure, ReferralReward>> claimReward(String rewardId);

  /// Attempts to apply the given referral [code] to the authenticated user's
  /// account.
  ///
  /// Returns `true` when the code was accepted and applied successfully.
  Future<Either<Failure, bool>> applyReferralCode(String code);

  /// Generates shareable text content (e.g. a WhatsApp-ready message) from the
  /// provided [referralCode].
  ///
  /// The returned [String] includes the [ReferralCode.deepLink] and a
  /// human-friendly invitation message.
  Future<Either<Failure, String>> generateShareContent(ReferralCode referralCode);

  /// Fetches the referral leaderboard entries.
  ///
  /// Each entry is a map with at least the keys `rank`, `name`, and
  /// `earnings`.  Using a `Map<String, dynamic>` keeps the domain layer
  /// decoupled from any specific leaderboard schema.
  Future<Either<Failure, List<Map<String, dynamic>>>> getLeaderboard();
}
