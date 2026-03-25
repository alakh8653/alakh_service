import 'dart:convert';

import 'package:mobile_app/core/error/exceptions.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/referral_code_model.dart';
import '../models/referral_stats_model.dart';

/// Cache keys used with [SharedPreferences].
class _CacheKeys {
  const _CacheKeys._();

  static const String referralCode = 'CACHED_REFERRAL_CODE';
  static const String referralStats = 'CACHED_REFERRAL_STATS';
}

/// Contract for the local data source that persists referral data on-device.
abstract class ReferralLocalDataSource {
  /// Returns the last successfully fetched [ReferralCodeModel] from the cache.
  ///
  /// Throws [CacheException] when no cached value is present.
  Future<ReferralCodeModel> getCachedReferralCode();

  /// Persists [referralCode] to the local cache.
  Future<void> cacheReferralCode(ReferralCodeModel referralCode);

  /// Returns the last successfully fetched [ReferralStatsModel] from the cache.
  ///
  /// Throws [CacheException] when no cached value is present.
  Future<ReferralStatsModel> getCachedReferralStats();

  /// Persists [stats] to the local cache.
  Future<void> cacheReferralStats(ReferralStatsModel stats);

  /// Removes all referral-related entries from the cache.
  Future<void> clearCache();
}

/// [ReferralLocalDataSource] implementation backed by [SharedPreferences].
class ReferralLocalDataSourceImpl implements ReferralLocalDataSource {
  /// Creates a [ReferralLocalDataSourceImpl] with the given [sharedPreferences]
  /// instance.
  const ReferralLocalDataSourceImpl({
    required SharedPreferences sharedPreferences,
  }) : _prefs = sharedPreferences;

  final SharedPreferences _prefs;

  @override
  Future<ReferralCodeModel> getCachedReferralCode() async {
    final jsonString = _prefs.getString(_CacheKeys.referralCode);
    if (jsonString == null) {
      throw const CacheException(message: 'No cached referral code found.');
    }
    final json = jsonDecode(jsonString) as Map<String, dynamic>;
    return ReferralCodeModel.fromJson(json);
  }

  @override
  Future<void> cacheReferralCode(ReferralCodeModel referralCode) async {
    await _prefs.setString(
      _CacheKeys.referralCode,
      jsonEncode(referralCode.toJson()),
    );
  }

  @override
  Future<ReferralStatsModel> getCachedReferralStats() async {
    final jsonString = _prefs.getString(_CacheKeys.referralStats);
    if (jsonString == null) {
      throw const CacheException(message: 'No cached referral stats found.');
    }
    final json = jsonDecode(jsonString) as Map<String, dynamic>;
    return ReferralStatsModel.fromJson(json);
  }

  @override
  Future<void> cacheReferralStats(ReferralStatsModel stats) async {
    await _prefs.setString(
      _CacheKeys.referralStats,
      jsonEncode(stats.toJson()),
    );
  }

  @override
  Future<void> clearCache() async {
    await Future.wait([
      _prefs.remove(_CacheKeys.referralCode),
      _prefs.remove(_CacheKeys.referralStats),
    ]);
  }
}
