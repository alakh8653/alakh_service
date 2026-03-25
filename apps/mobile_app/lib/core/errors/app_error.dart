/// Base error / failure classes following clean architecture.
///
/// The domain layer throws [AppError] subclasses; the presentation layer
/// maps them to user-facing messages via [ErrorMessages].
library app_error;

/// Base class for all domain errors.
///
/// Prefer using sealed subclasses ([NetworkFailure], [CacheFailure], etc.)
/// so switch expressions remain exhaustive.
sealed class AppError implements Exception {
  const AppError({required this.message, this.originalError});

  /// A developer-readable description of what went wrong.
  final String message;

  /// The original exception / error that caused this failure, if any.
  final Object? originalError;

  @override
  String toString() => '$runtimeType: $message';
}

// ── Domain failures ───────────────────────────────────────────────────────────

/// A network / HTTP failure (no connectivity, server error, etc.).
final class NetworkFailure extends AppError {
  const NetworkFailure({
    super.message = 'A network error occurred.',
    super.originalError,
    this.statusCode,
  });

  final int? statusCode;
}

/// A failure while reading from or writing to local cache / storage.
final class CacheFailure extends AppError {
  const CacheFailure({
    super.message = 'A cache error occurred.',
    super.originalError,
  });
}

/// The requested resource was not found.
final class NotFoundFailure extends AppError {
  const NotFoundFailure({
    super.message = 'The requested resource was not found.',
    super.originalError,
    this.resourceId,
  });

  final String? resourceId;
}

/// The user is not authenticated or the session has expired.
final class AuthFailure extends AppError {
  const AuthFailure({
    super.message = 'Authentication failed. Please log in again.',
    super.originalError,
  });
}

/// The user does not have permission to perform the requested action.
final class PermissionFailure extends AppError {
  const PermissionFailure({
    super.message = 'You do not have permission to perform this action.',
    super.originalError,
  });
}

/// Input validation failed.
final class ValidationFailure extends AppError {
  const ValidationFailure({
    super.message = 'Validation failed.',
    super.originalError,
    this.fieldErrors = const {},
  });

  /// Maps field names to lists of validation error messages.
  final Map<String, List<String>> fieldErrors;
}

/// An unexpected / unhandled error.
final class UnexpectedFailure extends AppError {
  const UnexpectedFailure({
    super.message = 'An unexpected error occurred.',
    super.originalError,
  });
}

/// A conflict error (e.g. optimistic concurrency conflict during sync).
final class ConflictFailure extends AppError {
  const ConflictFailure({
    super.message = 'A conflict occurred. Please refresh and try again.',
    super.originalError,
    this.conflictingId,
  });

  final String? conflictingId;
}

/// The operation timed out.
final class TimeoutFailure extends AppError {
  const TimeoutFailure({
    super.message = 'The operation timed out. Please try again.',
    super.originalError,
  });
}
