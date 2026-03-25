import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:mobile_app/core/error/failures.dart';

import '../entities/referral_reward.dart';
import '../repositories/referral_repository.dart';
import 'get_referral_code_usecase.dart';

/// Parameters required to claim a specific reward.
class ClaimRewardParams extends Equatable {
  /// Identifier of the reward to be claimed.
  final String rewardId;

  /// Creates [ClaimRewardParams].
  const ClaimRewardParams({required this.rewardId});

  @override
  List<Object?> get props => [rewardId];
}

/// Submits a claim for the [ReferralReward] identified by [ClaimRewardParams.rewardId].
///
/// On success, returns the updated [ReferralReward] reflecting the claimed
/// status.
class ClaimRewardUseCase implements UseCase<ReferralReward, ClaimRewardParams> {
  /// Creates a [ClaimRewardUseCase] with the given [repository].
  const ClaimRewardUseCase(this._repository);

  final ReferralRepository _repository;

  @override
  Future<Either<Failure, ReferralReward>> call(ClaimRewardParams params) =>
      _repository.claimReward(params.rewardId);
}
