/// General-purpose string utility functions.
class StringHelpers {
  StringHelpers._();

  /// Capitalises the first character of [s] and lowercases the rest.
  ///
  /// Returns an empty string when [s] is empty.
  static String capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1).toLowerCase();
  }

  /// Converts [s] to title case (each word capitalised).
  ///
  /// Example: `"hello world"` → `"Hello World"`
  static String titleCase(String s) =>
      s.split(' ').map(capitalize).join(' ');

  /// Truncates [s] to at most [maxLength] characters, appending [ellipsis]
  /// when truncation occurs.
  static String truncate(String s, int maxLength, {String ellipsis = '...'}) {
    if (s.length <= maxLength) return s;
    return '${s.substring(0, maxLength)}$ellipsis';
  }

  /// Converts [s] to a URL-friendly slug.
  ///
  /// Example: `"Hello World!"` → `"hello-world"`
  static String slugify(String s) => s
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9\s-]'), '')
      .trim()
      .replaceAll(RegExp(r'\s+'), '-');

  /// Masks an e-mail address for display purposes.
  ///
  /// Example: `"alice@gmail.com"` → `"al***@gmail.com"`
  static String maskEmail(String email) {
    final parts = email.split('@');
    if (parts.length != 2) return email;
    final local = parts[0];
    final domain = parts[1];
    if (local.length <= 2) return '***@$domain';
    return '${local.substring(0, 2)}***@$domain';
  }

  /// Masks a phone number for display purposes.
  ///
  /// Example: `"+91 9876543210"` → `"+91 ****43210"`
  static String maskPhone(String phone) {
    final digits = phone.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 5) return phone;
    final visible = digits.substring(digits.length - 5);
    final masked = '*' * (digits.length - 5);
    // Attempt to preserve any leading `+91` prefix.
    final prefix = phone.startsWith('+') ? '${phone.substring(0, 3)} ' : '';
    return '$prefix$masked$visible';
  }

  /// Extracts up to [maxChars] initials from [name].
  ///
  /// Example: `initials("John Doe")` → `"JD"`
  static String initials(String name, {int maxChars = 2}) {
    final words = name.trim().split(RegExp(r'\s+'));
    return words
        .where((w) => w.isNotEmpty)
        .take(maxChars)
        .map((w) => w[0].toUpperCase())
        .join();
  }

  /// Converts a camelCase or PascalCase string to space-separated words.
  ///
  /// Example: `camelToWords("camelCase")` → `"Camel Case"`
  static String camelToWords(String camel) {
    final result = camel.replaceAllMapped(
      RegExp(r'([A-Z])'),
      (m) => ' ${m[0]}',
    );
    return titleCase(result.trim());
  }

  /// Returns `true` when [s] is `null` or consists solely of whitespace.
  static bool isNullOrEmpty(String? s) => s == null || s.trim().isEmpty;

  /// Returns `null` when [s] is `null` or empty; otherwise returns [s].
  static String? emptyToNull(String? s) =>
      (s == null || s.trim().isEmpty) ? null : s;
}
