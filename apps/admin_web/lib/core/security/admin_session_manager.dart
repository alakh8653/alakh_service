import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:admin_web/core/security/admin_auth_service.dart';

class AdminSessionManager {
  static const _tokenKey = 'admin_token';
  static const _refreshTokenKey = 'admin_refresh_token';
  static const _userKey = 'admin_user';
  static const _expiryKey = 'admin_token_expiry';

  final SharedPreferences _prefs;

  AdminSessionManager(this._prefs);

  Future<void> saveSession(
    String token,
    String refreshToken,
    AdminUser user,
  ) async {
    final expiry = DateTime.now()
        .add(const Duration(hours: 8))
        .millisecondsSinceEpoch;

    await Future.wait([
      _prefs.setString(_tokenKey, token),
      _prefs.setString(_refreshTokenKey, refreshToken),
      _prefs.setString(_userKey, jsonEncode(user.toJson())),
      _prefs.setInt(_expiryKey, expiry),
    ]);
  }

  Future<void> clearSession() async {
    await Future.wait([
      _prefs.remove(_tokenKey),
      _prefs.remove(_refreshTokenKey),
      _prefs.remove(_userKey),
      _prefs.remove(_expiryKey),
    ]);
  }

  String? getToken() => _prefs.getString(_tokenKey);

  String? getRefreshToken() => _prefs.getString(_refreshTokenKey);

  bool isSessionValid() {
    final token = _prefs.getString(_tokenKey);
    if (token == null || token.isEmpty) return false;

    final expiry = _prefs.getInt(_expiryKey);
    if (expiry == null) return false;

    return DateTime.now().millisecondsSinceEpoch < expiry;
  }

  AdminUser? getUser() {
    final userJson = _prefs.getString(_userKey);
    if (userJson == null) return null;

    try {
      final map = jsonDecode(userJson) as Map<String, dynamic>;
      return AdminUser.fromJson(map);
    } catch (_) {
      return null;
    }
  }

  bool get hasRefreshToken {
    final refresh = _prefs.getString(_refreshTokenKey);
    return refresh != null && refresh.isNotEmpty;
  }
}
