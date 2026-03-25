import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/error/failures.dart';
import '../models/dispatch_job_model.dart';

/// Key used to persist the active job in shared preferences.
const _kActiveJobKey = 'dispatch_active_job';

/// Abstract contract for the local dispatch data source.
abstract class DispatchLocalDataSource {
  /// Returns the cached active job, or `null` if none is stored.
  Future<DispatchJobModel?> getCachedActiveJob();

  /// Persists [job] as the current active job.
  Future<void> cacheActiveJob(DispatchJobModel job);

  /// Removes the cached active job entry.
  Future<void> clearActiveJob();
}

/// [SharedPreferences]-backed implementation of [DispatchLocalDataSource].
class DispatchLocalDataSourceImpl implements DispatchLocalDataSource {
  final SharedPreferences _prefs;

  const DispatchLocalDataSourceImpl(this._prefs);

  @override
  Future<DispatchJobModel?> getCachedActiveJob() async {
    final jsonString = _prefs.getString(_kActiveJobKey);
    if (jsonString == null) return null;
    try {
      final decoded = json.decode(jsonString) as Map<String, dynamic>;
      return DispatchJobModel.fromJson(decoded);
    } catch (e) {
      throw CacheFailure(
        message: 'Cached active job is corrupted.',
        cause: e,
      );
    }
  }

  @override
  Future<void> cacheActiveJob(DispatchJobModel job) async {
    try {
      await _prefs.setString(_kActiveJobKey, json.encode(job.toJson()));
    } catch (e) {
      throw CacheFailure(
        message: 'Failed to cache active job.',
        cause: e,
      );
    }
  }

  @override
  Future<void> clearActiveJob() async {
    await _prefs.remove(_kActiveJobKey);
  }
}
