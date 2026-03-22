import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:mobile_app/core/error/failures.dart';

import '../entities/referral_code.dart';
import '../repositories/referral_repository.dart';
import 'get_referral_code_usecase.dart';

/// Parameters required for the share-referral use case.
class ShareReferralParams extends Equatable {
  /// The referral code whose deep-link and message will be generated.
  final ReferralCode referralCode;

  /// Creates [ShareReferralParams].
  const ShareReferralParams({required this.referralCode});

  @override
  List<Object?> get props => [referralCode];
}

/// Generates a shareable text string (e.g. for WhatsApp or SMS) incorporating
/// the user's [ReferralCode.deepLink] and a human-friendly invitation message.
///
/// The returned [String] is ready to be passed directly to the platform share
/// sheet.
class ShareReferralUseCase implements UseCase<String, ShareReferralParams> {
  /// Creates a [ShareReferralUseCase] with the given [repository].
  const ShareReferralUseCase(this._repository);

  final ReferralRepository _repository;

  @override
  Future<Either<Failure, String>> call(ShareReferralParams params) =>
      _repository.generateShareContent(params.referralCode);
}
