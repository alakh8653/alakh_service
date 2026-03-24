/// Common [Duration] constants used throughout the application.
abstract final class DurationConstants {
  // ── Animations ──────────────────────────────────────────────────────────────

  /// Fast UI animation: 150 ms.
  static const Duration animationFast = Duration(milliseconds: 150);

  /// Normal UI animation: 300 ms.
  static const Duration animationNormal = Duration(milliseconds: 300);

  /// Slow UI animation: 500 ms.
  static const Duration animationSlow = Duration(milliseconds: 500);

  // ── Rate limiting ────────────────────────────────────────────────────────────

  /// Default debounce delay: 300 ms.
  static const Duration debounce = Duration(milliseconds: 300);

  /// Default throttle interval: 500 ms.
  static const Duration throttle = Duration(milliseconds: 500);

  // ── Network ──────────────────────────────────────────────────────────────────

  /// Total time allowed for a request to complete: 30 s.
  static const Duration requestTimeout = Duration(seconds: 30);

  /// Time allowed to establish a connection: 10 s.
  static const Duration connectTimeout = Duration(seconds: 10);

  // ── Caching / Auth ───────────────────────────────────────────────────────────

  /// Default cache expiry: 5 minutes.
  static const Duration cacheExpiry = Duration(minutes: 5);

  /// How long before token expiry to trigger a refresh: 5 minutes.
  static const Duration tokenRefreshBuffer = Duration(minutes: 5);
}
