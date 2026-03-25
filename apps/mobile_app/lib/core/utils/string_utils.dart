/// String manipulation helpers.
library string_utils;

/// General-purpose string utilities.
abstract final class AppStringUtils {
  AppStringUtils._();

  // ── Case conversion ────────────────────────────────────────────────────────

  /// Capitalises the first character of [s] and lowercases the rest.
  static String capitalize(String s) =>
      s.isEmpty ? s : '${s[0].toUpperCase()}${s.substring(1).toLowerCase()}';

  /// Capitalises the first character of every word in [s].
  static String titleCase(String s) =>
      s.split(' ').map(capitalize).join(' ');

  /// Converts `camelCase` or `PascalCase` to `snake_case`.
  static String toSnakeCase(String s) => s
      .replaceAllMapped(
        RegExp(r'(?<=[a-z0-9])(?=[A-Z])'),
        (m) => '_',
      )
      .toLowerCase();

  /// Converts `snake_case` to `camelCase`.
  static String toCamelCase(String s) {
    final parts = s.split('_');
    if (parts.isEmpty) return s;
    return parts.first +
        parts.skip(1).map(capitalize).join();
  }

  // ── Truncation ─────────────────────────────────────────────────────────────

  /// Truncates [s] to [maxLength] characters, appending [ellipsis] if needed.
  static String truncate(String s, int maxLength, {String ellipsis = '…'}) {
    if (s.length <= maxLength) return s;
    return '${s.substring(0, maxLength - ellipsis.length)}$ellipsis';
  }

  // ── Validation helpers ─────────────────────────────────────────────────────

  /// Returns `true` if [s] is a valid e-mail address.
  static bool isValidEmail(String s) {
    final regex = RegExp(
      r'^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$',
    );
    return regex.hasMatch(s.trim());
  }

  /// Returns `true` if [s] is a valid phone number (E.164 or local 10-digit).
  static bool isValidPhone(String s) {
    final cleaned = s.replaceAll(RegExp(r'[\s\-()]'), '');
    return RegExp(r'^\+?[1-9]\d{9,14}$').hasMatch(cleaned);
  }

  /// Returns `true` if [s] contains at least [minLength] characters.
  static bool hasMinLength(String s, int minLength) =>
      s.length >= minLength;

  // ── Masking ────────────────────────────────────────────────────────────────

  /// Masks an email: `u***@example.com`.
  static String maskEmail(String email) {
    final parts = email.split('@');
    if (parts.length != 2) return email;
    final local = parts[0];
    final domain = parts[1];
    if (local.length <= 1) return '***@$domain';
    return '${local[0]}${'*' * (local.length - 1)}@$domain';
  }

  /// Masks a phone number, showing only the last 4 digits: `******1234`.
  static String maskPhone(String phone) {
    if (phone.length <= 4) return phone;
    return '${'*' * (phone.length - 4)}${phone.substring(phone.length - 4)}';
  }

  // ── Misc ───────────────────────────────────────────────────────────────────

  /// Returns `true` if [s] is `null` or empty after trimming.
  static bool isNullOrEmpty(String? s) => s == null || s.trim().isEmpty;

  /// Returns [fallback] if [s] is null or blank, otherwise returns [s].
  static String orElse(String? s, String fallback) =>
      isNullOrEmpty(s) ? fallback : s!;

  /// Generates initials from a full name (e.g. `'John Doe'` → `'JD'`).
  static String initials(String name, {int maxChars = 2}) {
    final words = name.trim().split(RegExp(r'\s+'));
    return words
        .take(maxChars)
        .map((w) => w.isEmpty ? '' : w[0].toUpperCase())
        .join();
  }

  /// Slugifies a string for URL usage (e.g. `'Hello World!'` → `'hello-world'`).
  static String slugify(String s) => s
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9\s-]'), '')
      .trim()
      .replaceAll(RegExp(r'\s+'), '-');
}
