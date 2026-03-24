import '../constants/regex_patterns.dart';

/// Validates e-mail addresses.
class EmailValidator {
  EmailValidator._();

  /// Returns an error message when [value] is not a valid e-mail address,
  /// or `null` when it is valid.
  ///
  /// Suitable for use as a `FormField` validator.
  static String? validate(String? value) {
    if (value == null || value.trim().isEmpty) return 'Email is required';
    if (!isValid(value)) return 'Enter a valid email address';
    return null;
  }

  /// Returns `true` when [value] is a syntactically valid e-mail address.
  static bool isValid(String value) =>
      RegexPatterns.email.hasMatch(value.trim());
}
