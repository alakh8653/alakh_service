import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:mobile_app/core/error/failures.dart';

import '../entities/referral_code.dart';
import '../repositories/referral_repository.dart';

/// Base contract for all use cases in the application.
///
/// [Type] is the success type returned inside the [Either].
/// [Params] carries any input parameters the use case needs; use [NoParams]
/// when no parameters are required.
abstract class UseCase<Type, Params> {
  /// Executes the use case.
  Future<Either<Failure, Type>> call(Params params);
}

/// Sentinel parameter type for use cases that require no input.
class NoParams extends Equatable {
  /// Creates a [NoParams] instance.
  const NoParams();

  @override
  List<Object?> get props => [];
}

/// Retrieves the authenticated user's unique [ReferralCode].
///
/// The repository handles cache-then-network resolution, so callers receive a
/// result even when the device is temporarily offline.
class GetReferralCodeUseCase implements UseCase<ReferralCode, NoParams> {
  /// Creates a [GetReferralCodeUseCase] with the given [repository].
  const GetReferralCodeUseCase(this._repository);

  final ReferralRepository _repository;

  @override
  Future<Either<Failure, ReferralCode>> call(NoParams params) =>
      _repository.getReferralCode();
}
