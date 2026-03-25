/// Application configuration with environment support.
///
/// Provides a singleton configuration object that holds all app-level
/// settings including API base URLs, feature toggles, and environment type.
library app_config;

/// Represents the deployment environment of the application.
enum AppEnvironment {
  /// Local development environment.
  dev,

  /// Staging / QA environment.
  staging,

  /// Production / live environment.
  production,
}

/// Central application configuration.
///
/// Use [AppConfig.instance] to access the singleton after calling
/// [AppConfig.initialize] once at app startup.
class AppConfig {
  AppConfig._({
    required this.environment,
    required this.baseUrl,
    required this.wsBaseUrl,
    required this.apiVersion,
    required this.apiKey,
    required this.enableLogging,
    required this.enableCrashReporting,
    required this.enableAnalytics,
    required this.enableOfflineMode,
    required this.enableBiometrics,
    required this.connectionTimeoutMs,
    required this.receiveTimeoutMs,
    required this.maxRetryAttempts,
  });

  static AppConfig? _instance;

  /// Returns the singleton [AppConfig] instance.
  ///
  /// Throws a [StateError] if [initialize] has not been called yet.
  static AppConfig get instance {
    if (_instance == null) {
      throw StateError(
        'AppConfig has not been initialized. '
        'Call AppConfig.initialize() before accessing AppConfig.instance.',
      );
    }
    return _instance!;
  }

  /// Initializes the singleton configuration.
  ///
  /// Must be called once, typically in `main.dart` or `bootstrap.dart`,
  /// before any other code that uses [AppConfig.instance].
  static void initialize({
    required AppEnvironment environment,
    required String baseUrl,
    required String wsBaseUrl,
    String apiVersion = 'v1',
    String apiKey = '',
    bool enableLogging = false,
    bool enableCrashReporting = false,
    bool enableAnalytics = false,
    bool enableOfflineMode = true,
    bool enableBiometrics = true,
    int connectionTimeoutMs = 30000,
    int receiveTimeoutMs = 30000,
    int maxRetryAttempts = 3,
  }) {
    _instance = AppConfig._(
      environment: environment,
      baseUrl: baseUrl,
      wsBaseUrl: wsBaseUrl,
      apiVersion: apiVersion,
      apiKey: apiKey,
      enableLogging: enableLogging,
      enableCrashReporting: enableCrashReporting,
      enableAnalytics: enableAnalytics,
      enableOfflineMode: enableOfflineMode,
      enableBiometrics: enableBiometrics,
      connectionTimeoutMs: connectionTimeoutMs,
      receiveTimeoutMs: receiveTimeoutMs,
      maxRetryAttempts: maxRetryAttempts,
    );
  }

  /// The current deployment environment.
  final AppEnvironment environment;

  /// Base URL for REST API calls (e.g. `https://api.example.com`).
  final String baseUrl;

  /// Base URL for WebSocket connections (e.g. `wss://ws.example.com`).
  final String wsBaseUrl;

  /// API version prefix appended to [baseUrl] (e.g. `v1`).
  final String apiVersion;

  /// Optional API key sent with every request via `X-Api-Key` header.
  final String apiKey;

  // ── Feature toggles ──────────────────────────────────────────────────────

  /// Whether verbose HTTP / app logging is enabled.
  final bool enableLogging;

  /// Whether crash reporting (e.g. Firebase Crashlytics) is enabled.
  final bool enableCrashReporting;

  /// Whether analytics event tracking is enabled.
  final bool enableAnalytics;

  /// Whether offline-mode and local sync queue are enabled.
  final bool enableOfflineMode;

  /// Whether biometric authentication is enabled.
  final bool enableBiometrics;

  // ── Network settings ─────────────────────────────────────────────────────

  /// HTTP connection timeout in milliseconds.
  final int connectionTimeoutMs;

  /// HTTP receive timeout in milliseconds.
  final int receiveTimeoutMs;

  /// Maximum number of automatic retry attempts for failed requests.
  final int maxRetryAttempts;

  // ── Convenience helpers ───────────────────────────────────────────────────

  /// Whether the app is running in the development environment.
  bool get isDev => environment == AppEnvironment.dev;

  /// Whether the app is running in the staging environment.
  bool get isStaging => environment == AppEnvironment.staging;

  /// Whether the app is running in the production environment.
  bool get isProduction => environment == AppEnvironment.production;

  /// Full base URL including the API version prefix.
  ///
  /// Example: `https://api.example.com/v1`
  String get fullBaseUrl => '$baseUrl/$apiVersion';

  @override
  String toString() => 'AppConfig('
      'env: $environment, '
      'baseUrl: $baseUrl, '
      'wsBaseUrl: $wsBaseUrl'
      ')';
}
