/// Environment configuration for admin_web.
///
/// Values are injected at build time via `--dart-define`.
/// Run the app with:
///   flutter run -d chrome \
///     --dart-define=API_BASE_URL=http://localhost:3000/api/v1 \
///     --dart-define=WS_BASE_URL=http://localhost:3000
abstract class Env {
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:3000/api/v1',
  );
  static const String wsBaseUrl = String.fromEnvironment(
    'WS_BASE_URL',
    defaultValue: 'http://localhost:3000',
  );
  static const String googleMapsApiKey = String.fromEnvironment(
    'GOOGLE_MAPS_API_KEY',
    defaultValue: '',
  );
  static const String sentryDsn = String.fromEnvironment(
    'SENTRY_DSN',
    defaultValue: '',
  );
  static const bool isProduction = bool.fromEnvironment('dart.vm.product');
}
