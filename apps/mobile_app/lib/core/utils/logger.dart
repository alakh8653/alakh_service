/// Logging utility with configurable log levels.
///
/// Provides a lightweight wrapper around `dart:developer` so that log calls
/// can be silenced in production and easily swapped for a structured logger.
library logger;

import 'dart:developer' as dev;

/// Log severity levels.
enum LogLevel {
  /// Fine-grained debug information.
  debug,

  /// General operational messages.
  info,

  /// Potentially harmful situations.
  warning,

  /// Error events that might still allow the app to continue.
  error,

  /// Very severe errors that will presumably abort the app.
  fatal,
}

/// Application logger.
///
/// Usage:
/// ```dart
/// final _log = AppLogger('MyFeature');
/// _log.d('Fetching user…');
/// _log.e('Failed to fetch user', error: e, stackTrace: stack);
/// ```
class AppLogger {
  /// Creates a logger with the given [tag] (displayed as the log name).
  const AppLogger(this.tag);

  /// Tag prepended to every log line (e.g. `'AuthRepository'`).
  final String tag;

  /// Global minimum level; messages below this are suppressed.
  static LogLevel minimumLevel = LogLevel.debug;

  /// Whether colours are emitted in the console output (ANSI codes).
  static bool useColors = true;

  // ── Convenience methods ────────────────────────────────────────────────────

  /// Logs a [LogLevel.debug] message.
  void d(String message, {Object? error, StackTrace? stackTrace}) =>
      _log(LogLevel.debug, message, error: error, stackTrace: stackTrace);

  /// Logs a [LogLevel.info] message.
  void i(String message, {Object? error, StackTrace? stackTrace}) =>
      _log(LogLevel.info, message, error: error, stackTrace: stackTrace);

  /// Logs a [LogLevel.warning] message.
  void w(String message, {Object? error, StackTrace? stackTrace}) =>
      _log(LogLevel.warning, message, error: error, stackTrace: stackTrace);

  /// Logs a [LogLevel.error] message.
  void e(String message, {Object? error, StackTrace? stackTrace}) =>
      _log(LogLevel.error, message, error: error, stackTrace: stackTrace);

  /// Logs a [LogLevel.fatal] message.
  void f(String message, {Object? error, StackTrace? stackTrace}) =>
      _log(LogLevel.fatal, message, error: error, stackTrace: stackTrace);

  // ── Core ───────────────────────────────────────────────────────────────────

  void _log(
    LogLevel level,
    String message, {
    Object? error,
    StackTrace? stackTrace,
  }) {
    if (level.index < minimumLevel.index) return;

    final prefix = _prefix(level);
    final full = '[$tag] $message';

    dev.log(
      '$prefix $full',
      name: tag,
      level: _dartLogLevel(level),
      error: error,
      stackTrace: stackTrace,
      time: DateTime.now(),
    );
  }

  String _prefix(LogLevel level) => switch (level) {
        LogLevel.debug   => useColors ? '\x1B[37m[D]\x1B[0m' : '[D]',
        LogLevel.info    => useColors ? '\x1B[34m[I]\x1B[0m' : '[I]',
        LogLevel.warning => useColors ? '\x1B[33m[W]\x1B[0m' : '[W]',
        LogLevel.error   => useColors ? '\x1B[31m[E]\x1B[0m' : '[E]',
        LogLevel.fatal   => useColors ? '\x1B[35m[F]\x1B[0m' : '[F]',
      };

  int _dartLogLevel(LogLevel level) => switch (level) {
        LogLevel.debug   => 500,
        LogLevel.info    => 800,
        LogLevel.warning => 900,
        LogLevel.error   => 1000,
        LogLevel.fatal   => 1200,
      };
}
