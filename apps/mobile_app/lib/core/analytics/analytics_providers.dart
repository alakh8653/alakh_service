/// Provider implementations for analytics (Firebase, Mixpanel, etc.).
library analytics_providers;

import '../utils/logger.dart';
import 'analytics_events.dart';
import 'user_properties.dart';

// ── Abstract provider ─────────────────────────────────────────────────────────

/// Abstract interface that every analytics backend must implement.
abstract class AnalyticsProvider {
  /// Tracks an event with the given [name] and optional [parameters].
  Future<void> trackEvent(
    String name, {
    Map<String, dynamic>? parameters,
  });

  /// Sets user-level properties on the analytics backend.
  Future<void> setUserProperties(UserProperties properties);

  /// Clears the user identity (on logout).
  Future<void> clearUser();

  /// Records a screen view.
  Future<void> setCurrentScreen(String screenName);
}

// ── No-op / console provider ──────────────────────────────────────────────────

/// No-op [AnalyticsProvider] that prints events to the debug console.
///
/// Used in development and as a safe fallback when no SDK is configured.
class ConsoleAnalyticsProvider implements AnalyticsProvider {
  ConsoleAnalyticsProvider();

  final _log = AppLogger('Analytics[Console]');

  @override
  Future<void> trackEvent(
    String name, {
    Map<String, dynamic>? parameters,
  }) async {
    _log.i('event: $name${parameters != null ? ' | $parameters' : ''}');
  }

  @override
  Future<void> setUserProperties(UserProperties properties) async {
    _log.i('setUser: ${properties.userId} (${properties.userType})');
  }

  @override
  Future<void> clearUser() async {
    _log.i('clearUser');
  }

  @override
  Future<void> setCurrentScreen(String screenName) async {
    _log.i('screen: $screenName');
  }
}

// ── Firebase Analytics stub ───────────────────────────────────────────────────

/// [AnalyticsProvider] backed by Firebase Analytics.
///
/// Add to pubspec.yaml:
/// ```yaml
/// dependencies:
///   firebase_analytics: ^10.10.0
/// ```
///
/// TODO: Uncomment and implement when Firebase is configured.
// class FirebaseAnalyticsProvider implements AnalyticsProvider {
//   FirebaseAnalyticsProvider({required FirebaseAnalytics analytics})
//       : _analytics = analytics;
//
//   final FirebaseAnalytics _analytics;
//
//   @override
//   Future<void> trackEvent(String name, {Map<String, dynamic>? parameters}) =>
//       _analytics.logEvent(name: name, parameters: parameters);
//
//   @override
//   Future<void> setUserProperties(UserProperties properties) async {
//     for (final entry in properties.toMap().entries) {
//       await _analytics.setUserProperty(
//           name: entry.key, value: entry.value.toString());
//     }
//   }
//
//   @override
//   Future<void> clearUser() =>
//       _analytics.setUserId(id: null);
//
//   @override
//   Future<void> setCurrentScreen(String screenName) =>
//       _analytics.setCurrentScreen(screenName: screenName);
// }

// ── Mixpanel stub ─────────────────────────────────────────────────────────────

/// [AnalyticsProvider] backed by Mixpanel.
///
/// TODO: Uncomment and implement when Mixpanel is configured.
// class MixpanelAnalyticsProvider implements AnalyticsProvider {
//   MixpanelAnalyticsProvider({required Mixpanel mixpanel})
//       : _mp = mixpanel;
//
//   final Mixpanel _mp;
//
//   @override
//   Future<void> trackEvent(String name, {Map<String, dynamic>? parameters}) async =>
//       _mp.track(name, properties: parameters);
//
//   @override
//   Future<void> setUserProperties(UserProperties props) async {
//     _mp.identify(props.userId);
//     _mp.getPeople().setMap(props.toMap().cast<String, Object>());
//   }
//
//   @override
//   Future<void> clearUser() async => _mp.reset();
//
//   @override
//   Future<void> setCurrentScreen(String screenName) async =>
//       _mp.track('screen_view', properties: {'screen_name': screenName});
// }
