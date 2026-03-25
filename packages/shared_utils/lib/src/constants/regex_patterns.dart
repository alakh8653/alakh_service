/// Compiled [RegExp] patterns used across the application.
abstract final class RegexPatterns {
  /// Matches a valid e-mail address (RFC 5322 simplified).
  static final RegExp email = RegExp(
    r'^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$',
  );

  /// Matches a valid Indian mobile number (10 significant digits, starting
  /// with 6–9), optionally prefixed with `+91` or `0`.
  static final RegExp phone = RegExp(
    r'^(\+91|0)?[6-9]\d{9}$',
  );

  /// Matches a password that has at least 8 characters, one uppercase letter,
  /// one lowercase letter, one digit, and one special character.
  static final RegExp password = RegExp(
    r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[!@#\$%^&*(),.?":{}|<>]).{8,}$',
  );

  /// Matches an HTTP or HTTPS URL.
  static final RegExp url = RegExp(
    r'^https?://[^\s/$.?#].[^\s]*$',
    caseSensitive: false,
  );

  /// Matches a string containing only letters and digits.
  static final RegExp alphanumeric = RegExp(r'^[a-zA-Z0-9]+$');

  /// Matches a string containing only digit characters.
  static final RegExp numericOnly = RegExp(r'^\d+$');

  /// Matches a positive number (integer or decimal).
  static final RegExp positiveNumber = RegExp(r'^\d+(\.\d+)?$');
}
