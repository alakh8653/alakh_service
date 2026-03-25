/// Build-flavor configuration.
///
/// Each flavor (dev, staging, prod) can have a distinct app name,
/// application ID / bundle identifier, and icon set. Values are read
/// from compile-time `--dart-define` constants so they are baked into
/// the binary rather than shipped as plain-text assets.
library build_config;

/// Holds per-flavor metadata that differs between build variants.
///
/// This class is `abstract final` so it cannot be instantiated;
/// all members are `static const` compile-time constants.
abstract final class BuildConfig {
  BuildConfig._();

  // ── Identity ──────────────────────────────────────────────────────────────

  /// Human-readable application name shown on the home screen.
  ///
  /// Injected via `--dart-define=APP_NAME="My App"`.
  static const String appName = String.fromEnvironment(
    'APP_NAME',
    defaultValue: 'AlakhService Dev',
  );

  /// Android application ID / iOS bundle identifier.
  ///
  /// Injected via `--dart-define=APP_BUNDLE_ID=com.example.app`.
  static const String bundleId = String.fromEnvironment(
    'APP_BUNDLE_ID',
    defaultValue: 'com.alakh.service.dev',
  );

  // ── Versioning ────────────────────────────────────────────────────────────

  /// Semantic version string (e.g. `2.3.1`).
  ///
  /// Injected via `--dart-define=APP_VERSION=2.3.1`.
  static const String version = String.fromEnvironment(
    'APP_VERSION',
    defaultValue: '1.0.0',
  );

  /// Integer build / version code.
  ///
  /// Injected via `--dart-define=BUILD_NUMBER=42`.
  static const int buildNumber = int.fromEnvironment(
    'BUILD_NUMBER',
    defaultValue: 1,
  );

  // ── Flavor ────────────────────────────────────────────────────────────────

  /// Active build flavor identifier.
  ///
  /// Accepted values: `dev`, `staging`, `production`.
  /// Injected via `--dart-define=BUILD_FLAVOR=dev`.
  static const String flavor = String.fromEnvironment(
    'BUILD_FLAVOR',
    defaultValue: 'dev',
  );

  /// Whether this is a debug build.
  ///
  /// `true` when running with `flutter run` without `--release`.
  static const bool isDebug = bool.fromEnvironment(
    'dart.vm.debug',
    defaultValue: true,
  );

  /// Whether this is a release / production build.
  static bool get isRelease => !isDebug;

  // ── Store URLs ────────────────────────────────────────────────────────────

  /// Google Play Store listing URL.
  ///
  /// Injected via `--dart-define=PLAY_STORE_URL=https://play.google.com/...`.
  static const String playStoreUrl = String.fromEnvironment(
    'PLAY_STORE_URL',
    defaultValue: '',
  );

  /// Apple App Store listing URL.
  ///
  /// Injected via `--dart-define=APP_STORE_URL=https://apps.apple.com/...`.
  static const String appStoreUrl = String.fromEnvironment(
    'APP_STORE_URL',
    defaultValue: '',
  );

  // ── Misc ─────────────────────────────────────────────────────────────────

  /// Deep-link / universal-link scheme used by the app.
  ///
  /// Injected via `--dart-define=DEEP_LINK_SCHEME=myapp`.
  static const String deepLinkScheme = String.fromEnvironment(
    'DEEP_LINK_SCHEME',
    defaultValue: 'alakhservice',
  );

  /// Whether the in-app update flow is enabled.
  ///
  /// Injected via `--dart-define=ENABLE_IN_APP_UPDATE=true`.
  static const bool enableInAppUpdate = bool.fromEnvironment(
    'ENABLE_IN_APP_UPDATE',
    defaultValue: false,
  );

  @override
  String toString() => 'BuildConfig('
      'appName: $appName, '
      'bundleId: $bundleId, '
      'version: $version+$buildNumber, '
      'flavor: $flavor'
      ')';
}
