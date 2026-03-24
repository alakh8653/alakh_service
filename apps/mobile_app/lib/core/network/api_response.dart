/// Generic API response wrapper.
///
/// Wraps every HTTP response into a typed [ApiResponse] so feature code
/// never has to deal with raw status codes or JSON parsing.
library api_response;

import 'dart:convert';

/// A discriminated union that is either a [SuccessResponse] or an
/// [ErrorResponse].
///
/// Usage:
/// ```dart
/// final result = await apiClient.get<User>('/users/me', fromJson: User.fromJson);
/// result.when(
///   success: (user) => print(user.name),
///   error: (err) => showErrorSnackbar(err.message),
/// );
/// ```
sealed class ApiResponse<T> {
  const ApiResponse();

  /// Whether this response represents a successful outcome.
  bool get isSuccess => this is SuccessResponse<T>;

  /// Whether this response represents a failure.
  bool get isError => this is ErrorResponse<T>;

  /// Returns the data if [isSuccess], otherwise `null`.
  T? get dataOrNull =>
      isSuccess ? (this as SuccessResponse<T>).data : null;

  /// Returns the error message if [isError], otherwise `null`.
  String? get errorMessageOrNull =>
      isError ? (this as ErrorResponse<T>).message : null;

  /// Calls [success] or [error] based on the variant.
  R when<R>({
    required R Function(T data) success,
    required R Function(String message, int? statusCode, Map<String, dynamic>? meta) error,
  }) {
    return switch (this) {
      SuccessResponse<T>(:final data) => success(data),
      ErrorResponse<T>(:final message, :final statusCode, :final meta) =>
        error(message, statusCode, meta),
    };
  }

  /// Maps a [SuccessResponse] data value to a different type.
  ApiResponse<R> map<R>(R Function(T data) mapper) {
    return switch (this) {
      SuccessResponse<T>(:final data) =>
        SuccessResponse<R>(data: mapper(data), statusCode: (this as SuccessResponse<T>).statusCode),
      ErrorResponse<T>(:final message, :final statusCode, :final meta, :final errors) =>
        ErrorResponse<R>(message: message, statusCode: statusCode, meta: meta, errors: errors),
    };
  }
}

/// Successful API response.
final class SuccessResponse<T> extends ApiResponse<T> {
  const SuccessResponse({
    required this.data,
    this.statusCode = 200,
    this.meta,
  });

  /// The decoded response body.
  final T data;

  /// HTTP status code (typically 200 or 201).
  final int statusCode;

  /// Optional metadata returned by the server (e.g. pagination info).
  final Map<String, dynamic>? meta;

  @override
  String toString() =>
      'SuccessResponse(statusCode: $statusCode, data: $data)';
}

/// Failed API response.
final class ErrorResponse<T> extends ApiResponse<T> {
  const ErrorResponse({
    required this.message,
    this.statusCode,
    this.meta,
    this.errors = const {},
  });

  /// Human-readable error message.
  final String message;

  /// HTTP status code, if available.
  final int? statusCode;

  /// Optional metadata (e.g. request ID for support tracing).
  final Map<String, dynamic>? meta;

  /// Field-level validation errors (for 422 responses).
  final Map<String, List<String>> errors;

  @override
  String toString() =>
      'ErrorResponse(statusCode: $statusCode, message: $message)';
}

// ── Pagination wrapper ─────────────────────────────────────────────────────────

/// Wraps a paginated list response.
class PaginatedResponse<T> {
  const PaginatedResponse({
    required this.data,
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
  });

  /// Deserialises from a standard Laravel-style paginated JSON body.
  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    final items = (json['data'] as List<dynamic>? ?? [])
        .map((e) => fromJson(e as Map<String, dynamic>))
        .toList();

    return PaginatedResponse(
      data: items,
      currentPage: json['current_page'] as int? ?? 1,
      lastPage: json['last_page'] as int? ?? 1,
      perPage: json['per_page'] as int? ?? items.length,
      total: json['total'] as int? ?? items.length,
    );
  }

  /// The list of decoded items on this page.
  final List<T> data;

  /// The current page number (1-based).
  final int currentPage;

  /// The last page number.
  final int lastPage;

  /// Items per page.
  final int perPage;

  /// Total number of items across all pages.
  final int total;

  /// Whether there is a next page.
  bool get hasNextPage => currentPage < lastPage;

  /// Whether this is the last page.
  bool get isLastPage => currentPage >= lastPage;

  @override
  String toString() =>
      'PaginatedResponse(page: $currentPage/$lastPage, total: $total)';
}
