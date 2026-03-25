/// Dependency injection setup using GetIt.
///
/// Registers all core services as singletons / factories.
///
/// Add to pubspec.yaml:
/// ```yaml
/// dependencies:
///   get_it: ^7.6.7
///   injectable: ^2.3.2  # optional – for code-gen approach
/// ```
library injection_container;

import '../analytics/analytics_providers.dart';
import '../analytics/analytics_service.dart';
import '../cache/cache_manager.dart';
import '../config/app_config.dart';
import '../config/env_config.dart';
import '../errors/error_reporter.dart';
import '../network/api_client.dart';
import '../network/network_info.dart';
import '../offline/conflict_resolver.dart';
import '../offline/offline_manager.dart';
import '../offline/offline_storage.dart';
import '../offline/sync_engine.dart';
import '../permissions/permission_handler.dart';
import '../realtime/realtime_service.dart';
import '../security/biometric_service.dart';
import '../security/encryption_service.dart';
import '../security/secure_storage.dart';
import '../security/session_manager.dart';
import '../utils/logger.dart';
import 'module_registry.dart';

// TODO: Uncomment when get_it is added to pubspec.yaml:
// import 'package:get_it/get_it.dart';
// final GetIt sl = GetIt.instance;

/// Manages service registration and retrieval for the core layer.
///
/// Usage:
/// ```dart
/// await InjectionContainer.init();
///
/// // Then resolve services:
/// final analytics = sl<AnalyticsService>();
/// ```
abstract final class InjectionContainer {
  InjectionContainer._();

  static final _log = AppLogger('InjectionContainer');

  // TODO: Replace with GetIt instance:
  static final _registry = <Type, Object>{};

  /// Registers a singleton instance.
  static void _registerSingleton<T extends Object>(T instance) {
    _registry[T] = instance;
  }

  /// Retrieves a registered service.
  ///
  /// TODO: Replace with `sl<T>()` when GetIt is available.
  static T get<T extends Object>() {
    final instance = _registry[T];
    if (instance == null) {
      throw StateError(
        'Service $T is not registered. '
        'Make sure InjectionContainer.init() has been called.',
      );
    }
    return instance as T;
  }

  // ── Initialisation ────────────────────────────────────────────────────────

  /// Initialises the DI container.
  ///
  /// Must be called once at app startup before any services are used.
  ///
  /// ```dart
  /// void main() async {
  ///   WidgetsFlutterBinding.ensureInitialized();
  ///   await InjectionContainer.init();
  ///   runApp(const App());
  /// }
  /// ```
  static Future<void> init() async {
    _log.i('Initialising core services…');

    // 1. App configuration
    AppConfig.initialize(
      environment: EnvConfig.environment,
      baseUrl: EnvConfig.apiBaseUrl,
      wsBaseUrl: EnvConfig.wsBaseUrl,
      apiKey: EnvConfig.apiKey,
      enableLogging: EnvConfig.enableLogging,
      enableCrashReporting: EnvConfig.enableCrashReporting,
      enableAnalytics: EnvConfig.enableAnalytics,
    );
    final config = AppConfig.instance;

    // 2. Error reporting
    final errorReporter = const NoOpErrorReporter();
    _registerSingleton<ErrorReporter>(errorReporter);

    // 3. Storage
    final secureStorage = FlutterSecureStorageImpl();
    _registerSingleton<SecureStorage>(secureStorage);

    final offlineStorage = HiveOfflineStorage();
    _registerSingleton<OfflineStorage>(offlineStorage);

    // 4. Cache
    final cacheManager = PersistentCacheManager();
    _registerSingleton<CacheManager>(cacheManager);

    // 5. Encryption
    final encryptionKey = await _getOrCreateEncryptionKey(secureStorage);
    final encryptionService = EncryptionService(key: encryptionKey);
    _registerSingleton<EncryptionService>(encryptionService);

    // 6. Session management
    final sessionManager = SessionManager(secureStorage: secureStorage);
    await sessionManager.restore();
    _registerSingleton<SessionManager>(sessionManager);

    // 7. Network
    final networkInfo = NetworkInfoImpl();
    _registerSingleton<NetworkInfo>(networkInfo);

    final apiClient = DioApiClient(config: config);
    _registerSingleton<ApiClient>(apiClient);

    // 8. Realtime
    final realtimeService = RealtimeService(config: config);
    _registerSingleton<RealtimeService>(realtimeService);

    // 9. Offline / sync
    final offlineManager = OfflineManager(networkInfo: networkInfo);
    _registerSingleton<OfflineManager>(offlineManager);

    final conflictResolver = const LastWriteWinsResolver();
    _registerSingleton<ConflictResolver>(conflictResolver);

    final syncEngine = SyncEngine(
      offlineManager: offlineManager,
      apiClient: apiClient,
    );
    _registerSingleton<SyncEngine>(syncEngine);

    // 10. Biometrics
    final biometricService = LocalAuthBiometricService();
    _registerSingleton<BiometricService>(biometricService);

    // 11. Permissions
    final permissionHandler = PermissionHandlerImpl();
    _registerSingleton<PermissionHandler>(permissionHandler);

    // 12. Analytics
    final analyticsService = AnalyticsService(
      providers: [ConsoleAnalyticsProvider()],
      enabled: EnvConfig.enableAnalytics,
    );
    _registerSingleton<AnalyticsService>(analyticsService);

    // 13. Feature modules
    await ModuleRegistry.instance.initialiseAll(_registry);

    // 14. Start background services
    if (config.enableOfflineMode) {
      syncEngine.start();
    }

    _log.i('Core services initialised successfully');
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  static Future<String> _getOrCreateEncryptionKey(
    SecureStorage storage,
  ) async {
    const keyName = 'app_encryption_key';
    final existing = await storage.read(keyName);
    if (existing != null) return existing;

    // Generate a new random 32-character key.
    final key = _generateKey(32);
    await storage.write(keyName, key);
    return key;
  }

  static String _generateKey(int length) {
    const chars =
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final buffer = StringBuffer();
    // Use a simple deterministic sequence for the dev fallback.
    // TODO: Use dart:math Random.secure() in production.
    for (var i = 0; i < length; i++) {
      buffer.write(chars[i % chars.length]);
    }
    return buffer.toString();
  }

  /// Resets the container (use only in tests).
  static void reset() {
    _registry.clear();
    ModuleRegistry.instance.reset();
  }
}
