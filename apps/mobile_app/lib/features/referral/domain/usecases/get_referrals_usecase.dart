import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:mobile_app/core/error/failures.dart';

import '../entities/referral.dart';
import '../repositories/referral_repository.dart';
import 'get_referral_code_usecase.dart';

/// Fetches the full list of referrals initiated by the authenticated user,
/// ordered by creation date (most recent first).
class GetReferralsUseCase implements UseCase<List<Referral>, NoParams> {
  /// Creates a [GetReferralsUseCase] with the given [repository].
  const GetReferralsUseCase(this._repository);

  final ReferralRepository _repository;

  @override
  Future<Either<Failure, List<Referral>>> call(NoParams params) =>
      _repository.getReferrals();
}
