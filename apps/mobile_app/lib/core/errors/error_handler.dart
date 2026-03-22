/// Global error handler that catches and processes errors.
///
/// Converts thrown exceptions into [AppError] domain failures and
/// optionally reports them to the [ErrorReporter].
library error_handler;

import '../network/api_exceptions.dart';
import '../utils/logger.dart';
import 'app_error.dart';
import 'error_reporter.dart';

/// Processes raw exceptions and converts them to typed [AppError] failures.
///
/// Use [ErrorHandler.handle] as a wrapper around repository / data-source
/// calls so that the domain layer only ever sees [AppError] types:
///
/// ```dart
/// final result = await ErrorHandler.handle(
///   () => remoteDataSource.fetchUser(id),
///   reporter: errorReporter,
/// );
/// ```
abstract final class ErrorHandler {
  ErrorHandler._();

  static final _log = AppLogger('ErrorHandler');

  /// Executes [operation] and maps any thrown exception to an [AppError].
  ///
  /// If [reporter] is provided, unrecoverable errors are also reported to
  /// the crash-reporting backend.
  static Future<T> handle<T>(
    Future<T> Function() operation, {
    ErrorReporter? reporter,
  }) async {
    try {
      return await operation();
    } on AppError {
      rethrow; // Already a domain error – pass through.
    } on AppNetworkException catch (e, stack) {
      final failure = _mapNetworkException(e);
      _log.e('Network error: ${failure.message}', error: e, stackTrace: stack);
      throw failure;
    } on FormatException catch (e, stack) {
      final failure = CacheFailure(
        message: 'Data format error: ${e.message}',
        originalError: e,
      );
      _log.e('Format error', error: e, stackTrace: stack);
      throw failure;
    } catch (e, stack) {
      final failure = UnexpectedFailure(message: e.toString(), originalError: e);
      _log.e('Unexpected error', error: e, stackTrace: stack);
      reporter?.report(e, stack);
      throw failure;
    }
  }

  /// Synchronous variant of [handle] for non-async operations.
  static T handleSync<T>(
    T Function() operation, {
    ErrorReporter? reporter,
  }) {
    try {
      return operation();
    } on AppError {
      rethrow;
    } catch (e, stack) {
      final failure = UnexpectedFailure(message: e.toString(), originalError: e);
      _log.e('Unexpected sync error', error: e, stackTrace: stack);
      reporter?.report(e, stack);
      throw failure;
    }
  }

  // ── Private helpers ───────────────────────────────────────────────────────

  static AppError _mapNetworkException(AppNetworkException e) =>
      switch (e) {
        NetworkException() => NetworkFailure(message: e.message, originalError: e),
        UnauthorizedException() => AuthFailure(message: e.message, originalError: e),
        ForbiddenException() => PermissionFailure(message: e.message, originalError: e),
        NotFoundException() =>
          NotFoundFailure(message: e.message, originalError: e),
        ValidationException(:final errors) =>
          ValidationFailure(message: e.message, originalError: e, fieldErrors: errors),
        TimeoutException() => TimeoutFailure(message: e.message, originalError: e),
        ServerException() =>
          NetworkFailure(message: e.message, statusCode: e.statusCode, originalError: e),
        _ => NetworkFailure(message: e.message, statusCode: e.statusCode, originalError: e),
      };
}
