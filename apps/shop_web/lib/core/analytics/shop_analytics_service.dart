/// Analytics service abstraction for the Shop Web application.
library;

import 'package:logger/logger.dart';

/// Provides a unified interface for logging analytics events, screen views,
/// and user / shop identifiers.
///
/// TODO(analytics): Integrate an actual analytics SDK (e.g. Firebase Analytics,
/// Amplitude, or Mixpanel) by replacing the log-only stubs below with real
/// SDK calls. The public API of this class is intentionally kept SDK-agnostic
/// so that the integration point is limited to this single file.
class ShopAnalyticsService {
  /// Creates a [ShopAnalyticsService].
  ///
  /// Supply a custom [logger] in tests to capture output without writing to
  /// the console.
  ShopAnalyticsService({Logger? logger})
      : _logger = logger ?? Logger(printer: PrettyPrinter(methodCount: 0));

  final Logger _logger;

  String? _userId;
  String? _shopId;

  // -------------------------------------------------------------------------
  // Identity
  // -------------------------------------------------------------------------

  /// Associates subsequent events with the given [userId].
  ///
  /// Call this after a successful login.
  Future<void> setUserId(String userId) async {
    _userId = userId;
    _logger.i('[Analytics] setUserId: $userId');
    // TODO(analytics): analytics_sdk.setUserId(userId);
  }

  /// Associates subsequent events with the given [shopId].
  ///
  /// Call this after the shop identity is resolved from the session.
  Future<void> setShopId(String shopId) async {
    _shopId = shopId;
    _logger.i('[Analytics] setShopId: $shopId');
    // TODO(analytics): analytics_sdk.setUserProperty('shop_id', shopId);
  }

  // -------------------------------------------------------------------------
  // Screen views
  // -------------------------------------------------------------------------

  /// Logs a screen-view event for [screenName].
  ///
  /// Should be called from each page's [initState] or [onEnter] lifecycle.
  Future<void> logScreenView(String screenName) async {
    _logger.i(
      '[Analytics] screenView: $screenName '
      '(userId: $_userId, shopId: $_shopId)',
    );
    // TODO(analytics): analytics_sdk.logScreenView(screenName: screenName);
  }

  // -------------------------------------------------------------------------
  // Custom events
  // -------------------------------------------------------------------------

  /// Logs a custom event with [name] and optional [parameters].
  ///
  /// Use the constants in [ShopAnalyticsEvents] for [name] to avoid typos.
  ///
  /// [parameters] values must be JSON-serialisable primitives (String, num,
  /// bool, or null). Collections are not supported by most analytics SDKs.
  Future<void> logEvent(
    String name, {
    Map<String, Object?>? parameters,
  }) async {
    final enriched = <String, Object?>{
      if (_userId != null) 'user_id': _userId,
      if (_shopId != null) 'shop_id': _shopId,
      ...?parameters,
    };

    _logger.i('[Analytics] event: $name | params: $enriched');
    // TODO(analytics): analytics_sdk.logEvent(name: name, parameters: enriched);
  }

  // -------------------------------------------------------------------------
  // Error tracking
  // -------------------------------------------------------------------------

  /// Records a non-fatal error event.
  ///
  /// Useful for logging recoverable failures that should be tracked without
  /// crashing the app.
  Future<void> logError(
    String description, {
    Object? error,
    StackTrace? stackTrace,
  }) async {
    _logger.e(
      '[Analytics] error: $description',
      error: error,
      stackTrace: stackTrace,
    );
    // TODO(analytics): analytics_sdk.recordError(error, stackTrace, fatal: false);
  }
}
