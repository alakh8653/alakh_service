import 'package:firebase_analytics/firebase_analytics.dart';

import 'analytics_service.dart';

/// Firebase Analytics implementation of [AnalyticsService].
class FirebaseAnalyticsProvider implements AnalyticsService {
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  @override
  Future<void> trackEvent(
    String eventName, {
    Map<String, dynamic>? properties,
  }) async {
    await _analytics.logEvent(
      name: _sanitizeEventName(eventName),
      parameters: properties?.map(
        (k, v) => MapEntry(k, v?.toString() ?? ''),
      ),
    );
  }

  @override
  Future<void> trackScreenView(
    String screenName, {
    String? screenClass,
  }) async {
    await _analytics.logScreenView(
      screenName: screenName,
      screenClass: screenClass,
    );
  }

  @override
  Future<void> setUserProperty(String name, String value) async {
    await _analytics.setUserProperty(name: name, value: value);
  }

  @override
  Future<void> identifyUser(
    String userId, {
    Map<String, dynamic>? traits,
  }) async {
    await _analytics.setUserId(id: userId);
    if (traits != null) {
      for (final entry in traits.entries) {
        await _analytics.setUserProperty(
          name: entry.key,
          value: entry.value?.toString(),
        );
      }
    }
  }

  @override
  Future<void> reset() async {
    await _analytics.setUserId(id: null);
  }

  /// Firebase event names must be 1–40 chars, alphanumeric + underscores, no leading digit.
  String _sanitizeEventName(String name) {
    return name.replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '_').substring(
          0,
          name.length > 40 ? 40 : name.length,
        );
  }
}

/// Multi-provider analytics implementation.
///
/// Dispatches events to all registered [AnalyticsService] providers simultaneously.
/// This allows running Firebase Analytics and a custom backend side-by-side.
class AnalyticsProvider implements AnalyticsService {
  AnalyticsProvider._();
  static final AnalyticsProvider instance = AnalyticsProvider._();

  final List<AnalyticsService> _providers = [];

  /// Registers an analytics provider.
  void addProvider(AnalyticsService provider) {
    _providers.add(provider);
  }

  /// Initializes with the default Firebase Analytics provider.
  void initializeWithDefaults() {
    _providers.add(FirebaseAnalyticsProvider());
  }

  @override
  Future<void> trackEvent(
    String eventName, {
    Map<String, dynamic>? properties,
  }) async {
    await Future.wait([
      for (final p in _providers)
        p.trackEvent(eventName, properties: properties),
    ]);
  }

  @override
  Future<void> trackScreenView(
    String screenName, {
    String? screenClass,
  }) async {
    await Future.wait([
      for (final p in _providers)
        p.trackScreenView(screenName, screenClass: screenClass),
    ]);
  }

  @override
  Future<void> setUserProperty(String name, String value) async {
    await Future.wait([
      for (final p in _providers) p.setUserProperty(name, value),
    ]);
  }

  @override
  Future<void> identifyUser(
    String userId, {
    Map<String, dynamic>? traits,
  }) async {
    await Future.wait([
      for (final p in _providers) p.identifyUser(userId, traits: traits),
    ]);
  }

  @override
  Future<void> reset() async {
    await Future.wait([for (final p in _providers) p.reset()]);
  }
}
