import 'package:equatable/equatable.dart';

/// Represents a structured error returned from the API.
class ApiError extends Equatable {
  /// Machine-readable error code (e.g. `'RESOURCE_NOT_FOUND'`).
  final String code;

  /// Human-readable error message.
  final String message;

  /// Optional map of field-level or context-specific error details.
  final Map<String, dynamic>? details;

  /// UTC timestamp at which the error was generated.
  final DateTime timestamp;

  const ApiError({
    required this.code,
    required this.message,
    this.details,
    required this.timestamp,
  });

  /// Creates an [ApiError] from a JSON map.
  factory ApiError.fromJson(Map<String, dynamic> json) => ApiError(
        code: json['code'] as String,
        message: json['message'] as String,
        details: json['details'] as Map<String, dynamic>?,
        timestamp: DateTime.parse(json['timestamp'] as String),
      );

  /// Converts this instance to a JSON map.
  Map<String, dynamic> toJson() => {
        'code': code,
        'message': message,
        if (details != null) 'details': details,
        'timestamp': timestamp.toIso8601String(),
      };

  /// Returns a copy with optionally overridden fields.
  ApiError copyWith({
    String? code,
    String? message,
    Map<String, dynamic>? details,
    DateTime? timestamp,
  }) =>
      ApiError(
        code: code ?? this.code,
        message: message ?? this.message,
        details: details ?? this.details,
        timestamp: timestamp ?? this.timestamp,
      );

  @override
  List<Object?> get props => [code, message, details, timestamp];

  @override
  String toString() =>
      'ApiError(code: $code, message: $message, details: $details, timestamp: $timestamp)';
}
