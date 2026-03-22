import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/error/failures.dart';
import '../models/location_model.dart';
import '../models/tracking_model.dart';

/// Abstract contract for local tracking cache operations.
abstract class TrackingLocalDataSource {
  /// Caches the last known [location] for [sessionId].
  Future<void> cacheLastLocation(String sessionId, LocationModel location);

  /// Returns the cached location for [sessionId], or null if absent.
  Future<LocationModel?> getLastLocation(String sessionId);

  /// Caches the active [session].
  Future<void> cacheActiveSession(TrackingModel session);

  /// Returns the cached active session, or null if absent.
  Future<TrackingModel?> getActiveSession();

  /// Clears the cached session and location for [sessionId].
  Future<void> clearSession(String sessionId);
}

/// Concrete [TrackingLocalDataSource] backed by [SharedPreferences].
class TrackingLocalDataSourceImpl implements TrackingLocalDataSource {
  /// The underlying preferences store.
  final SharedPreferences prefs;

  static const String _sessionKey = 'tracking_active_session';
  static String _locationKey(String sessionId) =>
      'tracking_location_$sessionId';

  /// Creates a [TrackingLocalDataSourceImpl].
  const TrackingLocalDataSourceImpl({required this.prefs});

  // ---------------------------------------------------------------------------
  // Cache last location
  // ---------------------------------------------------------------------------

  @override
  Future<void> cacheLastLocation(
      String sessionId, LocationModel location) async {
    await prefs.setString(
      _locationKey(sessionId),
      jsonEncode(location.toJson()),
    );
  }

  // ---------------------------------------------------------------------------
  // Get last location
  // ---------------------------------------------------------------------------

  @override
  Future<LocationModel?> getLastLocation(String sessionId) async {
    final raw = prefs.getString(_locationKey(sessionId));
    if (raw == null) return null;
    try {
      return LocationModel.fromJson(
          jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  // ---------------------------------------------------------------------------
  // Cache active session
  // ---------------------------------------------------------------------------

  @override
  Future<void> cacheActiveSession(TrackingModel session) async {
    await prefs.setString(_sessionKey, jsonEncode(session.toJson()));
  }

  // ---------------------------------------------------------------------------
  // Get active session
  // ---------------------------------------------------------------------------

  @override
  Future<TrackingModel?> getActiveSession() async {
    final raw = prefs.getString(_sessionKey);
    if (raw == null) return null;
    try {
      return TrackingModel.fromJson(
          jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  // ---------------------------------------------------------------------------
  // Clear session
  // ---------------------------------------------------------------------------

  @override
  Future<void> clearSession(String sessionId) async {
    await Future.wait([
      prefs.remove(_sessionKey),
      prefs.remove(_locationKey(sessionId)),
    ]);
  }
}
