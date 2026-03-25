import 'package:equatable/equatable.dart';

/// Represents a structured error response from the API server.
///
/// Servers are expected to return JSON bodies that conform to the shape:
/// ```json
/// {
///   "code": "VALIDATION_ERROR",
///   "message": "One or more fields are invalid.",
///   "fieldErrors": { "email": ["must be a valid email"] },
///   "statusCode": 422,
///   "timestamp": "2024-01-01T00:00:00Z"
/// }
/// ```
class ApiErrorResponse extends Equatable {
  /// A machine-readable error code (e.g. `"VALIDATION_ERROR"`).
  final String code;

  /// A human-readable error description.
  final String message;

  /// Per-field validation errors, keyed by field name.
  final Map<String, List<String>>? fieldErrors;

  /// The HTTP status code mirrored in the response body.
  final int? statusCode;

  /// ISO-8601 timestamp of when the error occurred, if provided by the server.
  final String? timestamp;

  const ApiErrorResponse({
    required this.code,
    required this.message,
    this.fieldErrors,
    this.statusCode,
    this.timestamp,
  });

  /// Deserializes an [ApiErrorResponse] from [json].
  factory ApiErrorResponse.fromJson(Map<String, dynamic> json) {
    Map<String, List<String>>? fieldErrors;
    final rawErrors = json['fieldErrors'];
    if (rawErrors is Map) {
      fieldErrors = rawErrors.map(
        (key, value) => MapEntry(
          key as String,
          (value as List).map((e) => e.toString()).toList(),
        ),
      );
    }

    return ApiErrorResponse(
      code: (json['code'] as String?) ?? 'UNKNOWN_ERROR',
      message: (json['message'] as String?) ?? 'An unexpected error occurred.',
      fieldErrors: fieldErrors,
      statusCode: (json['statusCode'] as num?)?.toInt(),
      timestamp: json['timestamp'] as String?,
    );
  }

  /// Serializes this [ApiErrorResponse] to a JSON-compatible map.
  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'message': message,
      if (fieldErrors != null) 'fieldErrors': fieldErrors,
      if (statusCode != null) 'statusCode': statusCode,
      if (timestamp != null) 'timestamp': timestamp,
    };
  }

  @override
  List<Object?> get props => [code, message, fieldErrors, statusCode, timestamp];
}
