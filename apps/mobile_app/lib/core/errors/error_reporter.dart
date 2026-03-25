/// Error reporting service (Crashlytics / Sentry integration).
///
/// Abstracts the crash-reporting SDK behind a simple interface so the rest
/// of the app can report errors without a hard dependency on any particular
/// SDK.
library error_reporter;

import '../utils/logger.dart';

/// Abstract interface for crash / error reporting.
abstract class ErrorReporter {
  /// Reports [error] with its [stackTrace] to the configured backend.
  void report(
    Object error,
    StackTrace? stackTrace, {
    Map<String, dynamic>? extras,
  });

  /// Records a non-fatal message (breadcrumb / log).
  void log(String message, {Map<String, dynamic>? extras});

  /// Sets a user identifier on all subsequent reports.
  void setUser(String userId, {String? email, String? name});

  /// Clears the user identifier (on logout).
  void clearUser();

  /// Sets an arbitrary key-value pair on future reports.
  void setCustomKey(String key, Object value);
}

// ── No-op implementation ──────────────────────────────────────────────────────

/// Default no-op [ErrorReporter] that only logs to the console.
///
/// Used in development and as a fallback when crash-reporting is disabled.
class NoOpErrorReporter implements ErrorReporter {
  const NoOpErrorReporter();

  final _log = const _DevLog();

  @override
  void report(
    Object error,
    StackTrace? stackTrace, {
    Map<String, dynamic>? extras,
  }) {
    _log.e('[ErrorReporter] $error', extras: extras);
  }

  @override
  void log(String message, {Map<String, dynamic>? extras}) {
    _log.i('[ErrorReporter] $message', extras: extras);
  }

  @override
  void setUser(String userId, {String? email, String? name}) {}

  @override
  void clearUser() {}

  @override
  void setCustomKey(String key, Object value) {}
}

// ── Firebase Crashlytics stub ─────────────────────────────────────────────────

/// [ErrorReporter] backed by Firebase Crashlytics.
///
/// Add to `pubspec.yaml`:
/// ```yaml
/// dependencies:
///   firebase_crashlytics: ^3.4.0
/// ```
///
/// TODO: Uncomment and implement when Crashlytics is configured.
// class CrashlyticsErrorReporter implements ErrorReporter {
//   @override
//   void report(Object error, StackTrace? stackTrace, {Map<String, dynamic>? extras}) {
//     FirebaseCrashlytics.instance.recordError(error, stackTrace, information: [
//       if (extras != null) ...extras.entries.map((e) => '${e.key}: ${e.value}'),
//     ]);
//   }
//
//   @override
//   void log(String message, {Map<String, dynamic>? extras}) {
//     FirebaseCrashlytics.instance.log(message);
//   }
//
//   @override
//   void setUser(String userId, {String? email, String? name}) {
//     FirebaseCrashlytics.instance.setUserIdentifier(userId);
//   }
//
//   @override
//   void clearUser() => FirebaseCrashlytics.instance.setUserIdentifier('');
//
//   @override
//   void setCustomKey(String key, Object value) {
//     FirebaseCrashlytics.instance.setCustomKey(key, value.toString());
//   }
// }

// ── Sentry stub ───────────────────────────────────────────────────────────────

/// [ErrorReporter] backed by Sentry.
///
/// Add to `pubspec.yaml`:
/// ```yaml
/// dependencies:
///   sentry_flutter: ^7.14.0
/// ```
///
/// TODO: Uncomment and implement when Sentry is configured.
// class SentryErrorReporter implements ErrorReporter {
//   @override
//   void report(Object error, StackTrace? stackTrace, {Map<String, dynamic>? extras}) {
//     Sentry.captureException(error, stackTrace: stackTrace, hint: extras != null ? Hint.withMap(extras) : null);
//   }
//
//   @override
//   void log(String message, {Map<String, dynamic>? extras}) {
//     Sentry.addBreadcrumb(Breadcrumb(message: message, data: extras));
//   }
//
//   @override
//   void setUser(String userId, {String? email, String? name}) {
//     Sentry.configureScope((scope) => scope.setUser(SentryUser(id: userId, email: email, name: name)));
//   }
//
//   @override
//   void clearUser() => Sentry.configureScope((scope) => scope.setUser(null));
//
//   @override
//   void setCustomKey(String key, Object value) {
//     Sentry.configureScope((scope) => scope.setTag(key, value.toString()));
//   }
// }

// ── Internal helper ───────────────────────────────────────────────────────────

class _DevLog {
  const _DevLog();

  void e(String msg, {Map<String, dynamic>? extras}) {
    // ignore: avoid_print
    print('[ERROR] $msg${extras != null ? ' | $extras' : ''}');
  }

  void i(String msg, {Map<String, dynamic>? extras}) {
    // ignore: avoid_print
    print('[INFO] $msg${extras != null ? ' | $extras' : ''}');
  }
}
