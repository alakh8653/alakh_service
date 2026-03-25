// Copyright (c) 2024 AlakhService. All rights reserved.
// Main entry point for the AlakhService mobile application.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'bootstrap.dart';

/// Environment configuration loaded from dart-defines at build time.
class Env {
  const Env._();

  /// Base URL for the backend API.
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://api.alakhservice.com',
  );

  /// Human-readable app name shown in the UI.
  static const String appName = String.fromEnvironment(
    'APP_NAME',
    defaultValue: 'AlakhService',
  );

  /// Current flavor / environment name (dev | staging | production).
  static const String flavor = String.fromEnvironment(
    'FLAVOR',
    defaultValue: 'production',
  );

  /// Whether verbose logging is enabled.
  static const bool enableLogging = bool.fromEnvironment(
    'ENABLE_LOGGING',
    defaultValue: false,
  );

  /// Whether mock services should be used instead of real network calls.
  static const bool useMockServices = bool.fromEnvironment(
    'USE_MOCK_SERVICES',
    defaultValue: false,
  );

  /// Sentry DSN for error reporting (leave empty to disable).
  static const String sentryDsn = String.fromEnvironment(
    'SENTRY_DSN',
    defaultValue: '',
  );

  /// Google Maps API key.
  static const String googleMapsApiKey = String.fromEnvironment(
    'GOOGLE_MAPS_API_KEY',
    defaultValue: '',
  );
}

/// Application entry point.
///
/// Sets up the error zone, loads environment configuration, initialises the
/// Flutter binding, and delegates further boot-up work to [bootstrap].
void main() {
  runZonedGuarded<Future<void>>(
    () async {
      // Ensure the Flutter engine is fully initialised before calling any
      // platform channels or plugin APIs.
      WidgetsFlutterBinding.ensureInitialized();

      // Constrain the device orientation to portrait only by default.
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);

      // Catch and report Flutter framework errors (widget build exceptions,
      // layout overflows, etc.) through the error-reporting pipeline.
      FlutterError.onError = (FlutterErrorDetails details) {
        FlutterError.presentError(details);
        // TODO(crashlytics): Forward to Firebase Crashlytics when integrated.
        // FirebaseCrashlytics.instance.recordFlutterFatalError(details);
        if (Env.enableLogging) {
          // ignore: avoid_print
          print('[FlutterError] ${details.exceptionAsString()}');
        }
      };

      await bootstrap(env: Env());
    },
    (Object error, StackTrace stack) {
      // Catch any uncaught asynchronous errors that escape the zone.
      // TODO(crashlytics): Forward to Firebase Crashlytics when integrated.
      // FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      debugPrint('[Zone Error] $error\n$stack');
    },
  );
}
