/// Wrapper around a successful or failed API response.
///
/// [T] is the type of the deserialized [data] payload.
class ApiResponse<T> {
  /// The deserialized response payload, or `null` on error / empty body.
  final T? data;

  /// The HTTP status code returned by the server.
  final int statusCode;

  /// An optional human-readable message included in the response body.
  final String? message;

  /// Whether the server indicated the operation succeeded.
  final bool success;

  const ApiResponse({
    this.data,
    required this.statusCode,
    this.message,
    required this.success,
  });

  /// Returns `true` when [success] is `true` and [statusCode] is 2xx.
  bool get isSuccess => success && statusCode >= 200 && statusCode < 300;

  /// Deserializes an [ApiResponse] from [json].
  ///
  /// [fromJsonT] is an optional converter applied to the `data` field. If
  /// omitted the raw JSON value is used as-is.
  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T? Function(dynamic)? fromJsonT,
  ) {
    final rawData = json['data'];
    final data = fromJsonT != null ? fromJsonT(rawData) : rawData as T?;

    return ApiResponse<T>(
      data: data,
      statusCode: (json['statusCode'] as num?)?.toInt() ?? 200,
      message: json['message'] as String?,
      success: (json['success'] as bool?) ?? true,
    );
  }

  /// Returns a copy of this response with the given fields replaced.
  ApiResponse<T> copyWith({
    T? data,
    int? statusCode,
    String? message,
    bool? success,
  }) {
    return ApiResponse<T>(
      data: data ?? this.data,
      statusCode: statusCode ?? this.statusCode,
      message: message ?? this.message,
      success: success ?? this.success,
    );
  }

  @override
  String toString() =>
      'ApiResponse(statusCode: $statusCode, success: $success, message: $message)';
}
