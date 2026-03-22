import 'package:dartz/dartz.dart';
import 'package:mobile_app/core/error/exceptions.dart';
import 'package:mobile_app/core/error/failures.dart';
import 'package:mobile_app/core/network/network_info.dart';

import '../../domain/entities/referral.dart';
import '../../domain/entities/referral_code.dart';
import '../../domain/entities/referral_reward.dart';
import '../../domain/entities/referral_stats.dart';
import '../../domain/repositories/referral_repository.dart';
import '../datasources/referral_local_datasource.dart';
import '../datasources/referral_remote_datasource.dart';
import '../models/referral_code_model.dart';

/// Concrete implementation of [ReferralRepository].
///
/// Uses a network-first strategy: always fetches from the remote data source
/// when the device is online, caches the result locally, and falls back to the
/// local cache when offline.
///
/// All failures are caught and mapped to the appropriate [Failure] subtype so
/// that the domain layer remains free of data-layer concerns.
class ReferralRepositoryImpl implements ReferralRepository {
  /// Creates a [ReferralRepositoryImpl].
  const ReferralRepositoryImpl({
    required ReferralRemoteDataSource remoteDataSource,
    required ReferralLocalDataSource localDataSource,
    required NetworkInfo networkInfo,
  })  : _remote = remoteDataSource,
        _local = localDataSource,
        _network = networkInfo;

  final ReferralRemoteDataSource _remote;
  final ReferralLocalDataSource _local;
  final NetworkInfo _network;

  @override
  Future<Either<Failure, ReferralCode>> getReferralCode() async {
    if (await _network.isConnected) {
      try {
        final model = await _remote.getReferralCode();
        await _local.cacheReferralCode(model);
        return Right(model);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      }
    } else {
      try {
        final cached = await _local.getCachedReferralCode();
        return Right(cached);
      } on CacheException catch (e) {
        return Left(CacheFailure(message: e.message));
      }
    }
  }

  @override
  Future<Either<Failure, ReferralStats>> getReferralStats() async {
    if (await _network.isConnected) {
      try {
        final model = await _remote.getReferralStats();
        await _local.cacheReferralStats(model);
        return Right(model);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      }
    } else {
      try {
        final cached = await _local.getCachedReferralStats();
        return Right(cached);
      } on CacheException catch (e) {
        return Left(CacheFailure(message: e.message));
      }
    }
  }

  @override
  Future<Either<Failure, List<Referral>>> getReferrals() async {
    if (!await _network.isConnected) {
      return const Left(NetworkFailure(
          message: 'No internet connection. Referral history is not cached.'));
    }
    try {
      final models = await _remote.getReferrals();
      return Right(models);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, ReferralReward>> claimReward(
      String rewardId) async {
    if (!await _network.isConnected) {
      return const Left(
          NetworkFailure(message: 'No internet connection. Cannot claim reward.'));
    }
    try {
      final model = await _remote.claimReward(rewardId);
      return Right(model);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, bool>> applyReferralCode(String code) async {
    if (!await _network.isConnected) {
      return const Left(NetworkFailure(
          message: 'No internet connection. Cannot apply referral code.'));
    }
    try {
      final success = await _remote.applyReferralCode(code);
      return Right(success);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, String>> generateShareContent(
      ReferralCode referralCode) async {
    // Share-content generation is done client-side; no network call needed.
    final String content;
    if (referralCode is ReferralCodeModel) {
      content = _buildShareMessage(referralCode);
    } else {
      // Fallback for plain domain entity (e.g. in tests / mocks).
      content =
          'Join me on Alakh Service and get a discount on your first booking! '
          'Use my referral code ${referralCode.code}: ${referralCode.deepLink}';
    }
    return Right(content);
  }

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> getLeaderboard() async {
    if (!await _network.isConnected) {
      return const Left(
          NetworkFailure(message: 'No internet connection. Cannot load leaderboard.'));
    }
    try {
      final entries = await _remote.getLeaderboard();
      return Right(entries);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

  String _buildShareMessage(ReferralCodeModel code) {
    final expiryNote = code.expiresAt != null
        ? ' (valid until ${_formatDate(code.expiresAt!)})'
        : '';
    return '🎉 Hey! I\'ve been using Alakh Service and loving it. '
        'Use my referral code *${code.code}*$expiryNote to get a special '
        'discount on your first booking.\n\n'
        '👉 Download & sign up here: ${code.deepLink}';
  }

  String _formatDate(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}/'
      '${date.month.toString().padLeft(2, '0')}/'
      '${date.year}';
}
