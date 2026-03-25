/// Common form-field validator functions.
library;

import '../constants/regex_patterns.dart';

/// A [FormFieldValidator] is a function that receives the current field value
/// and returns `null` when valid or an error message string when invalid.
typedef FormFieldValidator<T> = String? Function(T? value);

/// Collection of reusable form validators.
///
/// Each method returns a [FormFieldValidator] so validators can be composed
/// easily inside a [FormField.validator] list (see [ValidationRules]).
abstract final class FormValidators {
  // ---------------------------------------------------------------------------
  // Required
  // ---------------------------------------------------------------------------

  /// Ensures the field is not null and not empty after trimming.
  static FormFieldValidator<String> required({
    String message = 'This field is required.',
  }) =>
      (value) =>
          (value == null || value.trim().isEmpty) ? message : null;

  // ---------------------------------------------------------------------------
  // Length
  // ---------------------------------------------------------------------------

  /// Ensures the trimmed string is at least [min] characters long.
  static FormFieldValidator<String> minLength(
    int min, {
    String? message,
  }) =>
      (value) {
        if (value == null) return null;
        final trimmed = value.trim();
        if (trimmed.isEmpty) return null; // let [required] handle empty fields
        return trimmed.length < min
            ? (message ?? 'Minimum $min characters required.')
            : null;
      };

  /// Ensures the trimmed string does not exceed [max] characters.
  static FormFieldValidator<String> maxLength(
    int max, {
    String? message,
  }) =>
      (value) {
        if (value == null || value.trim().isEmpty) return null;
        return value.trim().length > max
            ? (message ?? 'Maximum $max characters allowed.')
            : null;
      };

  /// Ensures the trimmed string length falls within [[min], [max]].
  static FormFieldValidator<String> lengthRange(
    int min,
    int max, {
    String? message,
  }) =>
      (value) {
        if (value == null || value.trim().isEmpty) return null;
        final len = value.trim().length;
        return (len < min || len > max)
            ? (message ?? 'Must be between $min and $max characters.')
            : null;
      };

  // ---------------------------------------------------------------------------
  // Pattern / Format
  // ---------------------------------------------------------------------------

  /// Validates against [pattern].
  static FormFieldValidator<String> pattern(
    RegExp pattern, {
    String message = 'Invalid format.',
  }) =>
      (value) {
        if (value == null || value.trim().isEmpty) return null;
        return pattern.hasMatch(value.trim()) ? null : message;
      };

  /// Validates that the value is a properly formatted email address.
  static FormFieldValidator<String> email({
    String message = 'Enter a valid email address.',
  }) =>
      (value) {
        if (value == null || value.trim().isEmpty) return null;
        return RegexPatterns.email.hasMatch(value.trim()) ? null : message;
      };

  /// Validates an Indian mobile number.
  static FormFieldValidator<String> phone({
    String message = 'Enter a valid 10-digit mobile number.',
  }) =>
      (value) {
        if (value == null || value.trim().isEmpty) return null;
        return RegexPatterns.indianMobile.hasMatch(value.trim()) ? null : message;
      };

  /// Validates a strong password (≥8 chars, upper, lower, digit, special).
  static FormFieldValidator<String> strongPassword({
    String message =
        'Password must be at least 8 characters and include uppercase, '
            'lowercase, a digit, and a special character.',
  }) =>
      (value) {
        if (value == null || value.trim().isEmpty) return null;
        return RegexPatterns.strongPassword.hasMatch(value) ? null : message;
      };

  /// Checks that [value] matches [other] (useful for confirm-password).
  static FormFieldValidator<String> matches(
    String? Function() other, {
    String message = 'Values do not match.',
  }) =>
      (value) => value != other() ? message : null;

  // ---------------------------------------------------------------------------
  // Numeric
  // ---------------------------------------------------------------------------

  /// Ensures the field contains only digits.
  static FormFieldValidator<String> numeric({
    String message = 'Only numbers are allowed.',
  }) =>
      (value) {
        if (value == null || value.trim().isEmpty) return null;
        return RegexPatterns.digitsOnly.hasMatch(value.trim()) ? null : message;
      };

  /// Ensures the numeric value is at least [min].
  static FormFieldValidator<String> minValue(
    num min, {
    String? message,
  }) =>
      (value) {
        if (value == null || value.trim().isEmpty) return null;
        final parsed = num.tryParse(value.trim());
        if (parsed == null) return 'Enter a valid number.';
        return parsed < min
            ? (message ?? 'Value must be at least $min.')
            : null;
      };

  /// Ensures the numeric value does not exceed [max].
  static FormFieldValidator<String> maxValue(
    num max, {
    String? message,
  }) =>
      (value) {
        if (value == null || value.trim().isEmpty) return null;
        final parsed = num.tryParse(value.trim());
        if (parsed == null) return 'Enter a valid number.';
        return parsed > max
            ? (message ?? 'Value must be at most $max.')
            : null;
      };

  // ---------------------------------------------------------------------------
  // Alphabetic
  // ---------------------------------------------------------------------------

  /// Ensures the field contains only alphabetic characters.
  static FormFieldValidator<String> alphabetic({
    String message = 'Only letters are allowed.',
  }) =>
      (value) {
        if (value == null || value.trim().isEmpty) return null;
        return RegexPatterns.alphaOnly.hasMatch(value.trim()) ? null : message;
      };

  // ---------------------------------------------------------------------------
  // URL
  // ---------------------------------------------------------------------------

  /// Validates a well-formed http/https URL.
  static FormFieldValidator<String> url({
    String message = 'Enter a valid URL (must start with http:// or https://).',
  }) =>
      (value) {
        if (value == null || value.trim().isEmpty) return null;
        return RegexPatterns.url.hasMatch(value.trim()) ? null : message;
      };
}
