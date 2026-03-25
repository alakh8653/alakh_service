import '../formatters/phone_formatter.dart';

/// Validates Indian phone numbers.
class PhoneValidator {
  PhoneValidator._();

  /// Returns an error message when [value] is not a valid Indian phone number,
  /// or `null` when it is valid.
  ///
  /// Accepts numbers with or without the `+91` / `0` prefix.
  static String? validate(String? value) {
    if (value == null || value.trim().isEmpty) return 'Phone number is required';
    if (!isValid(value)) return 'Enter a valid 10-digit phone number';
    return null;
  }

  /// Returns `true` when [value] represents a valid Indian mobile number.
  ///
  /// The number may be prefixed with `+91` or `0`.
  /// The significant part must start with `6–9` and be exactly 10 digits.
  static bool isValid(String value) => PhoneFormatter.isValid(value.trim());
}
