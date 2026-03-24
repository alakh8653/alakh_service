/// Environment configuration for mobile_app.
///
/// Values are injected at build time via `--dart-define`.
/// Run the app with:
///   flutter run --dart-define=API_BASE_URL=http://10.0.2.2:3000/api/v1 \
///               --dart-define=WS_BASE_URL=http://10.0.2.2:3000
abstract class Env {
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:3000/api/v1',
  );
  static const String wsBaseUrl = String.fromEnvironment(
    'WS_BASE_URL',
    defaultValue: 'http://localhost:3000',
  );
  static const String razorpayKeyId = String.fromEnvironment(
    'RAZORPAY_KEY_ID',
    defaultValue: '',
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
