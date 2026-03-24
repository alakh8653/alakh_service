import 'api_exception.dart';

/// Thrown when the server responds with HTTP 422 Unprocessable Entity.
///
/// [fieldErrors] maps field names to lists of human-readable error messages,
/// enabling fine-grained form validation feedback.
class ValidationException extends ApiException {
  /// Per-field validation errors returned by the server.
  final Map<String, List<String>> fieldErrors;

  const ValidationException({
    super.message = 'Validation failed.',
    super.statusCode = 422,
    super.data,
    this.fieldErrors = const {},
  });

  /// Returns all error messages for [field], or an empty list if none exist.
  List<String> errorsFor(String field) => fieldErrors[field] ?? const [];

  @override
  String toString() =>
      'ValidationException: $message | fieldErrors: $fieldErrors';
}
