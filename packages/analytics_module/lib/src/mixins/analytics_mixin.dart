import '../analytics_provider.dart';
import '../analytics_service.dart';

/// A mixin for BLoC/Cubit classes that auto-tracks screen views and events.
///
/// Usage:
/// ```dart
/// class BookingCubit extends Cubit<BookingState> with AnalyticsMixin {
///   BookingCubit() : super(BookingInitial()) {
///     trackScreenView('booking_screen');
///   }
/// }
/// ```
mixin AnalyticsMixin {
  AnalyticsService get _analytics => AnalyticsProvider.instance;

  /// Tracks a screen view. Call in the constructor or [onInit] of your BLoC/Cubit.
  Future<void> trackScreenView(
    String screenName, {
    String? screenClass,
  }) {
    return _analytics.trackScreenView(
      screenName,
      screenClass: screenClass,
    );
  }

  /// Tracks an event with optional properties.
  Future<void> trackEvent(
    String eventName, {
    Map<String, dynamic>? properties,
  }) {
    return _analytics.trackEvent(eventName, properties: properties);
  }
}
