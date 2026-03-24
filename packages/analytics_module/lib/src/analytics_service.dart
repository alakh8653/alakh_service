/// Abstract analytics interface.
///
/// Implement this to add a new analytics backend (Firebase, Mixpanel, custom).
abstract class AnalyticsService {
  /// Tracks a named event with optional properties.
  Future<void> trackEvent(
    String eventName, {
    Map<String, dynamic>? properties,
  });

  /// Records a screen view.
  Future<void> trackScreenView(
    String screenName, {
    String? screenClass,
  });

  /// Sets a property on the current user's analytics profile.
  Future<void> setUserProperty(String name, String value);

  /// Identifies the current user for downstream analytics tools.
  Future<void> identifyUser(String userId, {Map<String, dynamic>? traits});

  /// Clears the current user identity (e.g. after logout).
  Future<void> reset();
}
