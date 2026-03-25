import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/trust_profile_model.dart';

abstract class TrustLocalDataSource {
  Future<void> cacheTrustProfile(TrustProfileModel profile);
  Future<TrustProfileModel?> getCachedTrustProfile(String userId);
  Future<void> clearCache();
}

class TrustLocalDataSourceImpl implements TrustLocalDataSource {
  final SharedPreferences sharedPreferences;
  static const String _profilePrefix = 'cached_trust_profile_';

  const TrustLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<void> cacheTrustProfile(TrustProfileModel profile) async {
    await sharedPreferences.setString(
      '$_profilePrefix${profile.userId}',
      jsonEncode(profile.toJson()),
    );
  }

  @override
  Future<TrustProfileModel?> getCachedTrustProfile(String userId) async {
    final jsonString =
        sharedPreferences.getString('$_profilePrefix$userId');
    if (jsonString == null) return null;
    return TrustProfileModel.fromJson(
        jsonDecode(jsonString) as Map<String, dynamic>);
  }

  @override
  Future<void> clearCache() async {
    final keys = sharedPreferences
        .getKeys()
        .where((k) => k.startsWith(_profilePrefix))
        .toList();
    for (final key in keys) {
      await sharedPreferences.remove(key);
    }
  }
}
