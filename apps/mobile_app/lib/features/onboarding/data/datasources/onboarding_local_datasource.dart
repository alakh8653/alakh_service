import 'dart:convert';

import '../models/models.dart';

/// Contract for local (cache) onboarding data operations.
abstract class OnboardingLocalDataSource {
  /// Returns `true` if the user has completed onboarding.
  Future<bool> isOnboardingCompleted();

  /// Persists the onboarding-completed flag.
  Future<void> setOnboardingCompleted();

  /// Persists [preferences] to local storage.
  Future<void> cachePreferences(UserPreferencesModel preferences);

  /// Returns the cached [UserPreferencesModel], or `null` if not found.
  Future<UserPreferencesModel?> getCachedPreferences();
}

/// [OnboardingLocalDataSource] implementation backed by SharedPreferences.
class OnboardingLocalDataSourceImpl implements OnboardingLocalDataSource {
  // TODO(dev): Inject SharedPreferences and replace _fakeStorage with it.
  //   Example:
  //     final SharedPreferences _prefs;
  //     OnboardingLocalDataSourceImpl(this._prefs);
  final Map<String, String> _fakeStorage = {};

  static const _keyCompleted = 'onboarding_completed';
  static const _keyPreferences = 'onboarding_preferences';

  @override
  Future<bool> isOnboardingCompleted() async {
    // TODO(dev): return _prefs.getBool(_keyCompleted) ?? false;
    return _fakeStorage[_keyCompleted] == 'true';
  }

  @override
  Future<void> setOnboardingCompleted() async {
    // TODO(dev): await _prefs.setBool(_keyCompleted, true);
    _fakeStorage[_keyCompleted] = 'true';
  }

  @override
  Future<void> cachePreferences(UserPreferencesModel preferences) async {
    // TODO(dev): await _prefs.setString(_keyPreferences, jsonEncode(preferences.toJson()));
    _fakeStorage[_keyPreferences] = jsonEncode(preferences.toJson());
  }

  @override
  Future<UserPreferencesModel?> getCachedPreferences() async {
    // TODO(dev): final raw = _prefs.getString(_keyPreferences);
    final raw = _fakeStorage[_keyPreferences];
    if (raw == null) return null;
    return UserPreferencesModel.fromJson(
      jsonDecode(raw) as Map<String, dynamic>,
    );
  }
}
