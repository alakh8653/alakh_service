import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:mobile_app/core/error/failures.dart';

import '../repositories/referral_repository.dart';
import 'get_referral_code_usecase.dart';

/// Parameters required to apply a referral code.
class ApplyReferralCodeParams extends Equatable {
  /// The referral code string to apply, e.g. `"ALAKH20"`.
  final String code;

  /// Creates [ApplyReferralCodeParams].
  const ApplyReferralCodeParams({required this.code});

  @override
  List<Object?> get props => [code];
}

/// Applies the referral code provided in [ApplyReferralCodeParams.code] to the
/// authenticated user's account.
///
/// Returns `true` when the server accepts the code.  Returns a [Failure] if
/// the code is invalid, already used, or the server rejects it.
class ApplyReferralCodeUseCase
    implements UseCase<bool, ApplyReferralCodeParams> {
  /// Creates an [ApplyReferralCodeUseCase] with the given [repository].
  const ApplyReferralCodeUseCase(this._repository);

  final ReferralRepository _repository;

  @override
  Future<Either<Failure, bool>> call(ApplyReferralCodeParams params) =>
      _repository.applyReferralCode(params.code);
}
