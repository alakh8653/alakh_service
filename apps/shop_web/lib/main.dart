/// Application entry point for the Shop Web dashboard.
library;

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:url_strategy/url_strategy.dart';

import 'app.dart';

final Logger _log = Logger(printer: PrettyPrinter(methodCount: 2));

/// Bootstraps the application.
///
/// Execution order:
/// 1. Initialise Flutter bindings.
/// 2. Use path-based URL strategy (removes the `#` from web URLs).
/// 3. Register all dependencies via the service locator.
/// 4. Install a global Flutter error handler.
/// 5. Wrap [runApp] in [runZonedGuarded] to capture unhandled async errors.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Remove the hash fragment from web URLs (e.g. `/dashboard` vs `/#/dashboard`).
  usePathUrlStrategy();

  // TODO(di): Call configureDependencies() once the injectable setup is
  // complete (requires running `flutter pub run build_runner build`).
  // await configureDependencies();

  // Route Flutter framework errors to the logger.
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    _log.e(
      'Flutter framework error',
      error: details.exception,
      stackTrace: details.stack,
    );
  };

  // Capture errors on the platform dispatcher (e.g. in web workers).
  PlatformDispatcher.instance.onError = (error, stack) {
    _log.e('PlatformDispatcher error', error: error, stackTrace: stack);
    return true; // Handled.
  };

  // Wrap runApp to catch unhandled errors in the root zone.
  runZonedGuarded(
    () => runApp(const ShopApp()),
    (error, stack) {
      _log.e('Unhandled zone error', error: error, stackTrace: stack);
    },
  );
}
