import '../constants/regex_patterns.dart';

/// Validates HTTP and HTTPS URLs.
class UrlValidator {
  UrlValidator._();

  /// Returns an error message when [value] is not a valid HTTP/HTTPS URL,
  /// or `null` when it is valid.
  static String? validate(String? value) {
    if (value == null || value.trim().isEmpty) return 'URL is required';
    if (!isValid(value)) return 'Enter a valid URL (https://...)';
    return null;
  }

  /// Returns `true` when [value] is a valid HTTP or HTTPS URL.
  static bool isValid(String value) =>
      RegexPatterns.url.hasMatch(value.trim());
}
