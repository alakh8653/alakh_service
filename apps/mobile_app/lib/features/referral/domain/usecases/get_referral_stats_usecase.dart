import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:mobile_app/core/error/failures.dart';

import '../entities/referral_stats.dart';
import '../repositories/referral_repository.dart';
import 'get_referral_code_usecase.dart';

/// Retrieves aggregated [ReferralStats] for the authenticated user.
class GetReferralStatsUseCase implements UseCase<ReferralStats, NoParams> {
  /// Creates a [GetReferralStatsUseCase] with the given [repository].
  const GetReferralStatsUseCase(this._repository);

  final ReferralRepository _repository;

  @override
  Future<Either<Failure, ReferralStats>> call(NoParams params) =>
      _repository.getReferralStats();
}
