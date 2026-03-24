/// Analytics abstraction layer supporting multiple providers.
library analytics_service;

import '../utils/logger.dart';
import 'analytics_events.dart';
import 'analytics_providers.dart';
import 'user_properties.dart';

/// Fan-out analytics service that forwards events to all registered providers.
///
/// Usage:
/// ```dart
/// final analytics = AnalyticsService(
///   providers: [FirebaseAnalyticsProvider(), MixpanelProvider()],
/// );
/// await analytics.track(SearchEvent(query: 'barber'));
/// ```
class AnalyticsService {
  AnalyticsService({
    List<AnalyticsProvider>? providers,
    this.enabled = true,
  }) : _providers = providers ?? [ConsoleAnalyticsProvider()];

  final List<AnalyticsProvider> _providers;

  /// When `false`, all tracking calls are silently ignored.
  bool enabled;

  final _log = AppLogger('AnalyticsService');

  // ── Event tracking ────────────────────────────────────────────────────────

  /// Tracks a typed [AnalyticsEvent].
  Future<void> track(AnalyticsEvent event) => trackRaw(
        event.name,
        parameters: event.toParameters(),
      );

  /// Tracks a raw event by [name] with optional [parameters].
  Future<void> trackRaw(
    String name, {
    Map<String, dynamic>? parameters,
  }) async {
    if (!enabled) return;
    for (final provider in _providers) {
      try {
        await provider.trackEvent(name, parameters: parameters);
      } catch (e) {
        _log.e('Provider ${provider.runtimeType} failed to track "$name": $e');
      }
    }
  }

  // ── User identity ─────────────────────────────────────────────────────────

  /// Sets user properties on all providers.
  Future<void> identifyUser(UserProperties properties) async {
    if (!enabled) return;
    for (final provider in _providers) {
      try {
        await provider.setUserProperties(properties);
      } catch (e) {
        _log.e('Provider ${provider.runtimeType} failed identifyUser: $e');
      }
    }
  }

  /// Clears the user identity on all providers (call on logout).
  Future<void> clearUser() async {
    for (final provider in _providers) {
      try {
        await provider.clearUser();
      } catch (e) {
        _log.e('Provider ${provider.runtimeType} failed clearUser: $e');
      }
    }
  }

  // ── Screen tracking ───────────────────────────────────────────────────────

  /// Records a screen view on all providers.
  Future<void> setCurrentScreen(String screenName) async {
    if (!enabled) return;
    for (final provider in _providers) {
      try {
        await provider.setCurrentScreen(screenName);
      } catch (e) {
        _log.e(
          'Provider ${provider.runtimeType} failed setCurrentScreen: $e',
        );
      }
    }
  }

  // ── Provider management ───────────────────────────────────────────────────

  /// Adds a new [provider] to the fan-out list.
  void addProvider(AnalyticsProvider provider) => _providers.add(provider);

  /// Removes a provider by runtime type.
  void removeProviderOfType<T extends AnalyticsProvider>() =>
      _providers.removeWhere((p) => p is T);
}
