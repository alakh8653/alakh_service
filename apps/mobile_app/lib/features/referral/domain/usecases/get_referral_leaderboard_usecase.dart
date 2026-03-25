import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:mobile_app/core/error/failures.dart';

import '../repositories/referral_repository.dart';
import 'get_referral_code_usecase.dart';

/// Fetches the referral leaderboard entries.
///
/// Each entry in the returned list is a `Map<String, dynamic>` with at least
/// the keys:
/// - `rank` (int) – the user's position on the leaderboard.
/// - `name` (String) – display name of the user.
/// - `earnings` (double) – total referral earnings.
/// - `isCurrentUser` (bool) – whether this entry belongs to the viewer.
class GetReferralLeaderboardUseCase
    implements UseCase<List<Map<String, dynamic>>, NoParams> {
  /// Creates a [GetReferralLeaderboardUseCase] with the given [repository].
  const GetReferralLeaderboardUseCase(this._repository);

  final ReferralRepository _repository;

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> call(NoParams params) =>
      _repository.getLeaderboard();
}
