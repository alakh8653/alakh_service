import '../constants/regex_patterns.dart';
import '../helpers/string_helpers.dart';

/// Convenient extension methods on [String].
extension StringExtensions on String {
  /// Returns this string with the first letter capitalised and the rest
  /// lowercased.
  String capitalize() => StringHelpers.capitalize(this);

  /// Returns this string converted to title case.
  String titleCase() => StringHelpers.titleCase(this);

  /// Truncates this string to [max] characters, appending `...` if needed.
  String truncate(int max, {String ellipsis = '...'}) =>
      StringHelpers.truncate(this, max, ellipsis: ellipsis);

  /// Returns `true` when this string is a valid e-mail address.
  bool get isEmail => RegexPatterns.email.hasMatch(trim());

  /// Returns `true` when this string is a valid Indian phone number.
  bool get isPhone => RegexPatterns.phone.hasMatch(trim());

  /// Returns `true` when this string is a valid HTTP/HTTPS URL.
  bool get isUrl => RegexPatterns.url.hasMatch(trim());

  /// Converts this string to a URL-friendly slug.
  String toSlug() => StringHelpers.slugify(this);

  /// Returns up to [maxChars] uppercase initials from this name string.
  String initials({int maxChars = 2}) =>
      StringHelpers.initials(this, maxChars: maxChars);

  /// Masks the local part of an e-mail address.
  ///
  /// Example: `"alice@example.com".maskEmail()` → `"al***@example.com"`
  String maskEmail() => StringHelpers.maskEmail(this);

  /// Masks a phone number, showing only the last 5 digits.
  ///
  /// Example: `"+91 9876543210".maskPhone()` → `"+91 ****43210"`
  String maskPhone() => StringHelpers.maskPhone(this);
}

/// Convenient extension methods on nullable [String].
extension NullableStringExtensions on String? {
  /// Returns `true` when this value is `null` or blank.
  bool get isNullOrEmpty => StringHelpers.isNullOrEmpty(this);
}
