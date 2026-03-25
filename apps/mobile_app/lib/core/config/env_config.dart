/// Environment-specific configuration loader.
///
/// Reads values injected via `--dart-define` at build time (or `.env`-style
/// variables when using a code-generation approach) and exposes them as typed
/// constants to the rest of the app.
library env_config;

import 'app_config.dart';

/// Loads and exposes all `--dart-define` compile-time constants.
///
/// Usage in `main.dart`:
/// ```dart
/// void main() {
///   AppConfig.initialize(
///     environment: EnvConfig.environment,
///     baseUrl: EnvConfig.apiBaseUrl,
///     wsBaseUrl: EnvConfig.wsBaseUrl,
///     apiKey: EnvConfig.apiKey,
///     enableLogging: EnvConfig.enableLogging,
///     enableCrashReporting: EnvConfig.enableCrashReporting,
///     enableAnalytics: EnvConfig.enableAnalytics,
///   );
///   runApp(const App());
/// }
/// ```
///
/// All constants default to sensible development values so the app
/// compiles without any `--dart-define` flags during local development.
abstract final class EnvConfig {
  EnvConfig._();

  // ── Environment ───────────────────────────────────────────────────────────

  /// Raw environment string injected at build time.
  ///
  /// Accepted values: `dev`, `staging`, `production`.
  static const String _rawEnvironment = String.fromEnvironment(
    'APP_ENV',
    defaultValue: 'dev',
  );

  /// Parsed [AppEnvironment] derived from [_rawEnvironment].
  static AppEnvironment get environment {
    switch (_rawEnvironment) {
      case 'production':
        return AppEnvironment.production;
      case 'staging':
        return AppEnvironment.staging;
      default:
        return AppEnvironment.dev;
    }
  }

  // ── API ───────────────────────────────────────────────────────────────────

  /// Base URL for REST API requests.
  ///
  /// Injected via `--dart-define=API_BASE_URL=https://api.example.com`.
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://dev-api.example.com',
  );

  /// Base URL for WebSocket connections.
  ///
  /// Injected via `--dart-define=WS_BASE_URL=wss://ws.example.com`.
  static const String wsBaseUrl = String.fromEnvironment(
    'WS_BASE_URL',
    defaultValue: 'wss://dev-ws.example.com',
  );

  /// API key for authenticating with the backend.
  ///
  /// Injected via `--dart-define=API_KEY=<key>`.
  static const String apiKey = String.fromEnvironment(
    'API_KEY',
    defaultValue: '',
  );

  // ── Feature flags ─────────────────────────────────────────────────────────

  /// Whether verbose logging is enabled.
  ///
  /// Injected via `--dart-define=ENABLE_LOGGING=true`.
  static const bool enableLogging = bool.fromEnvironment(
    'ENABLE_LOGGING',
    defaultValue: true,
  );

  /// Whether crash reporting is enabled.
  ///
  /// Injected via `--dart-define=ENABLE_CRASH_REPORTING=false`.
  static const bool enableCrashReporting = bool.fromEnvironment(
    'ENABLE_CRASH_REPORTING',
    defaultValue: false,
  );

  /// Whether analytics tracking is enabled.
  ///
  /// Injected via `--dart-define=ENABLE_ANALYTICS=false`.
  static const bool enableAnalytics = bool.fromEnvironment(
    'ENABLE_ANALYTICS',
    defaultValue: false,
  );

  // ── Sentry / Crashlytics DSN ──────────────────────────────────────────────

  /// Sentry DSN for error reporting.
  ///
  /// Injected via `--dart-define=SENTRY_DSN=https://...`.
  static const String sentryDsn = String.fromEnvironment(
    'SENTRY_DSN',
    defaultValue: '',
  );

  /// Firebase project ID for Crashlytics.
  ///
  /// Injected via `--dart-define=FIREBASE_PROJECT_ID=my-project`.
  static const String firebaseProjectId = String.fromEnvironment(
    'FIREBASE_PROJECT_ID',
    defaultValue: '',
  );

  // ── Misc ─────────────────────────────────────────────────────────────────

  /// App version name (e.g. `1.0.0`).
  ///
  /// Injected via `--dart-define=APP_VERSION=1.0.0`.
  static const String appVersion = String.fromEnvironment(
    'APP_VERSION',
    defaultValue: '1.0.0',
  );

  /// App build number.
  ///
  /// Injected via `--dart-define=BUILD_NUMBER=1`.
  static const int buildNumber = int.fromEnvironment(
    'BUILD_NUMBER',
    defaultValue: 1,
  );
}
