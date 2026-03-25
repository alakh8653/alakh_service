/// Feature module registration for lazy loading.
///
/// Each feature (auth, booking, etc.) implements [FeatureModule] and calls
/// [ModuleRegistry.register] from its own `di.dart` file.
/// [InjectionContainer.initModules] then activates all registered modules.
library module_registry;

import '../utils/logger.dart';

// ── Feature module interface ──────────────────────────────────────────────────

/// A self-contained set of DI registrations for a feature.
///
/// Implement this in each feature's DI file:
/// ```dart
/// class AuthModule implements FeatureModule {
///   @override
///   String get name => 'auth';
///
///   @override
///   Future<void> register(GetIt sl) async {
///     sl.registerFactory<LoginBloc>(() => LoginBloc(sl(), sl()));
///     sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(sl(), sl()));
///   }
/// }
/// ```
abstract class FeatureModule {
  /// Human-readable name used for logging.
  String get name;

  /// Registers all services, repositories, and blocs with the service locator.
  ///
  /// [sl] is the GetIt instance; cast it as needed.
  Future<void> register(dynamic sl);
}

// ── Registry ──────────────────────────────────────────────────────────────────

/// Maintains the list of [FeatureModule]s that should be initialised.
class ModuleRegistry {
  ModuleRegistry._();

  static final ModuleRegistry instance = ModuleRegistry._();

  final _modules = <FeatureModule>[];
  final _log = AppLogger('ModuleRegistry');
  bool _initialised = false;

  /// Registers a [FeatureModule] to be initialised later.
  ///
  /// Must be called before [initialiseAll].
  void register(FeatureModule module) {
    if (_initialised) {
      throw StateError(
        'Cannot register module "${module.name}" after initialisation.',
      );
    }
    _modules.add(module);
    _log.d('Registered module: ${module.name}');
  }

  /// Initialises all registered modules in the order they were registered.
  ///
  /// [sl] is the GetIt service-locator instance.
  Future<void> initialiseAll(dynamic sl) async {
    if (_initialised) {
      _log.w('ModuleRegistry.initialiseAll called more than once – ignoring');
      return;
    }
    _log.i('Initialising ${_modules.length} module(s)…');
    for (final module in _modules) {
      _log.d('Initialising module: ${module.name}');
      await module.register(sl);
    }
    _initialised = true;
    _log.i('All modules initialised');
  }

  /// Returns a read-only list of all registered modules.
  List<FeatureModule> get modules => List.unmodifiable(_modules);

  /// Whether [initialiseAll] has been called.
  bool get isInitialised => _initialised;

  /// Resets the registry (use only in tests).
  void reset() {
    _modules.clear();
    _initialised = false;
  }
}
