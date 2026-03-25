/// Common regular-expression patterns used throughout the app.
library;

/// Provides pre-compiled [RegExp] instances and raw pattern strings for
/// the most frequently needed validation and parsing scenarios.
abstract final class RegexPatterns {
  // ---------------------------------------------------------------------------
  // Contact
  // ---------------------------------------------------------------------------

  /// Validates a standard email address.
  ///
  /// Accepts most RFC-5321 compliant addresses, while staying readable.
  static final RegExp email = RegExp(
    r'^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$',
  );

  /// Validates an Indian mobile number (10 digits, optionally prefixed with
  /// `+91` or `0`).
  static final RegExp indianMobile = RegExp(
    r'^(?:\+91|0)?[6-9]\d{9}$',
  );

  /// Validates an international phone number in E.164 format
  /// (e.g. `+14155552671`).
  static final RegExp e164Phone = RegExp(r'^\+[1-9]\d{7,14}$');

  // ---------------------------------------------------------------------------
  // URLs & Web
  // ---------------------------------------------------------------------------

  /// Validates a URL with http or https scheme.
  static final RegExp url = RegExp(
    r'^https?://[^\s/$.?#].[^\s]*$',
    caseSensitive: false,
  );

  /// Validates a URL slug (alphanumeric and hyphens, no leading/trailing
  /// hyphens, no consecutive hyphens).
  static final RegExp slug = RegExp(r'^[a-z0-9]+(?:-[a-z0-9]+)*$');

  // ---------------------------------------------------------------------------
  // Identity / Codes
  // ---------------------------------------------------------------------------

  /// Validates a standard UUID v4.
  static final RegExp uuidV4 = RegExp(
    r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
    caseSensitive: false,
  );

  /// Validates a 6-digit numeric OTP.
  static final RegExp otp6 = RegExp(r'^\d{6}$');

  /// Validates an Indian PAN number (e.g. `ABCDE1234F`).
  static final RegExp pan = RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]{1}$');

  /// Validates an Indian Aadhaar number (12 digits).
  static final RegExp aadhaar = RegExp(r'^\d{12}$');

  /// Validates an Indian GST number.
  static final RegExp gst = RegExp(
    r'^\d{2}[A-Z]{5}\d{4}[A-Z][1-9A-Z]Z[0-9A-Z]$',
  );

  /// Validates an Indian IFSC code.
  static final RegExp ifsc = RegExp(r'^[A-Z]{4}0[A-Z0-9]{6}$');

  // ---------------------------------------------------------------------------
  // Payments
  // ---------------------------------------------------------------------------

  /// Validates a 16-digit credit/debit card number (no spaces).
  static final RegExp cardNumber = RegExp(r'^\d{16}$');

  /// Validates a card expiry in MM/YY format.
  static final RegExp cardExpiry = RegExp(
    r'^(0[1-9]|1[0-2])\/(\d{2})$',
  );

  /// Validates a 3- or 4-digit CVV.
  static final RegExp cvv = RegExp(r'^\d{3,4}$');

  // ---------------------------------------------------------------------------
  // Names & Text
  // ---------------------------------------------------------------------------

  /// Validates a name containing only letters (including Unicode) and spaces.
  static final RegExp name = RegExp(r"^[\p{L}\s'-]+$", unicode: true);

  /// Validates that a string contains only numeric digits.
  static final RegExp digitsOnly = RegExp(r'^\d+$');

  /// Validates that a string contains only alphabetic characters (ASCII).
  static final RegExp alphaOnly = RegExp(r'^[a-zA-Z]+$');

  /// Validates that a string contains only alphanumeric characters.
  static final RegExp alphanumeric = RegExp(r'^[a-zA-Z0-9]+$');

  // ---------------------------------------------------------------------------
  // Password
  // ---------------------------------------------------------------------------

  /// Strong password: at least 8 characters, one uppercase, one lowercase,
  /// one digit, and one special character.
  static final RegExp strongPassword = RegExp(
    r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[!@#\$&*~]).{8,}$',
  );

  // ---------------------------------------------------------------------------
  // Formatting helpers (raw strings)
  // ---------------------------------------------------------------------------

  /// Matches one or more consecutive whitespace characters.
  static final RegExp whitespace = RegExp(r'\s+');

  /// Matches HTML tags.
  static final RegExp htmlTag = RegExp(r'<[^>]*>');

  /// Matches leading and trailing whitespace.
  static final RegExp leadingTrailingWhitespace = RegExp(r'^\s+|\s+$');
}
