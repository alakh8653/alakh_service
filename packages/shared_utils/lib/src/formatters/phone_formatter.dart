/// Utility class for formatting and normalising phone numbers.
class PhoneFormatter {
  PhoneFormatter._();

  /// Strips all non-digit characters from [phone].
  ///
  /// Example: `"+91 98765-43210"` → `"919876543210"`
  static String normalize(String phone) => phone.replaceAll(RegExp(r'\D'), '');

  /// Returns only the significant digits of [phone] (without country code).
  ///
  /// Strips a leading `91` prefix when the normalized number has 12 digits.
  static String parse(String phone) {
    final digits = normalize(phone);
    if (digits.length == 12 && digits.startsWith('91')) {
      return digits.substring(2);
    }
    if (digits.length == 11 && digits.startsWith('0')) {
      return digits.substring(1);
    }
    return digits;
  }

  /// Formats [phone] with the given [countryCode] prefix.
  ///
  /// Example: `format("9876543210")` → `"+91 9876543210"`
  static String format(String phone, {String countryCode = '+91'}) {
    final digits = parse(phone);
    if (digits.length == 10) {
      return '$countryCode $digits';
    }
    // Return as-is if the number doesn't look like a 10-digit number.
    return phone;
  }

  /// Returns `true` when [phone] is a valid 10-digit Indian mobile number,
  /// optionally prefixed with `+91` or `0`.
  static bool isValid(String phone) {
    final digits = parse(phone);
    return RegExp(r'^[6-9]\d{9}$').hasMatch(digits);
  }
}
