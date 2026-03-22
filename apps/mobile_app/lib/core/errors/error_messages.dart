/// User-friendly error message mappings.
///
/// Maps [AppError] subtypes and HTTP status codes to localised strings
/// that are safe to display in the UI.
library error_messages;

import 'app_error.dart';

/// Provides human-readable messages for [AppError] instances.
abstract final class ErrorMessages {
  ErrorMessages._();

  // ── Status-code messages ──────────────────────────────────────────────────

  /// Returns a generic message for the given HTTP [statusCode].
  static String forStatusCode(int statusCode) => switch (statusCode) {
        400 => 'Bad request. Please check your input and try again.',
        401 => 'Your session has expired. Please log in again.',
        403 => 'You don\'t have permission to do that.',
        404 => 'The resource you\'re looking for doesn\'t exist.',
        408 => 'The request timed out. Please try again.',
        409 => 'A conflict occurred. Please refresh and try again.',
        422 => 'Some fields contain invalid values. Please review and resubmit.',
        429 => 'Too many requests. Please slow down and try again shortly.',
        500 => 'Something went wrong on our end. We\'re working on it.',
        502 => 'Service temporarily unavailable. Please try again later.',
        503 => 'The service is down for maintenance. Please check back soon.',
        504 => 'The server took too long to respond. Please try again.',
        _ => 'An unexpected error occurred (HTTP $statusCode).',
      };

  // ── AppError messages ─────────────────────────────────────────────────────

  /// Returns a user-friendly message for an [AppError].
  static String forError(AppError error) => switch (error) {
        NetworkFailure(:final statusCode) when statusCode != null =>
          forStatusCode(statusCode),
        NetworkFailure() =>
          'No internet connection. Please check your network and try again.',
        CacheFailure() =>
          'Failed to load cached data. Please try again.',
        NotFoundFailure() =>
          'The item you\'re looking for doesn\'t exist or has been removed.',
        AuthFailure() =>
          'Your session has expired. Please log in again.',
        PermissionFailure() =>
          'You don\'t have permission to perform this action.',
        ValidationFailure(:final fieldErrors) when fieldErrors.isNotEmpty =>
          fieldErrors.values.expand((e) => e).first,
        ValidationFailure() =>
          'Please check the highlighted fields and try again.',
        ConflictFailure() =>
          'A conflict occurred. Please refresh and try again.',
        TimeoutFailure() =>
          'The operation took too long. Please try again.',
        UnexpectedFailure() =>
          'Something unexpected happened. Please try again.',
      };

  // ── Network-specific messages ─────────────────────────────────────────────

  static const String noInternet =
      'No internet connection. Please check your network.';

  static const String serverError =
      'Server error. Our team has been notified.';

  static const String sessionExpired =
      'Your session has expired. Please log in again.';

  static const String genericRetry =
      'Something went wrong. Please try again.';

  static const String timeout =
      'The request timed out. Please try again.';

  // ── Auth-specific messages ────────────────────────────────────────────────

  static const String invalidCredentials =
      'Incorrect email or password. Please try again.';

  static const String accountLocked =
      'Your account has been locked. Please contact support.';

  static const String otpExpired =
      'The OTP has expired. Please request a new one.';

  static const String otpInvalid =
      'Invalid OTP. Please check and try again.';

  // ── Permission messages ────────────────────────────────────────────────────

  static const String cameraPermissionDenied =
      'Camera access is required for this feature. Please enable it in Settings.';

  static const String locationPermissionDenied =
      'Location access is required to find nearby services.';

  static const String notificationPermissionDenied =
      'Enable notifications to stay updated on your bookings.';
}
