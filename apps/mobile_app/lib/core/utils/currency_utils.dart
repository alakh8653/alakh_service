/// Currency formatting utilities.
library currency_utils;

/// Currency formatting and parsing helpers.
abstract final class CurrencyUtils {
  CurrencyUtils._();

  // ── Formatting ────────────────────────────────────────────────────────────

  /// Formats [amount] (in major currency units) with the given [symbol].
  ///
  /// Examples:
  /// ```dart
  /// CurrencyUtils.format(1234.5);           // '₹1,234.50'
  /// CurrencyUtils.format(1234.5, symbol: '$'); // '$1,234.50'
  /// ```
  static String format(
    double amount, {
    String symbol = '₹',
    int decimalDigits = 2,
    String thousandsSeparator = ',',
    String decimalSeparator = '.',
  }) {
    final isNegative = amount < 0;
    final absAmount = amount.abs();

    // Format integer part with thousands separator
    final intPart = absAmount.toInt();
    final intStr = _formatWithThousands(intPart, thousandsSeparator);

    // Format decimal part
    final decimalPart = (absAmount - intPart)
        .toStringAsFixed(decimalDigits)
        .substring(1); // Remove leading '0'

    final formatted = '$symbol$intStr$decimalPart';
    return isNegative ? '-$formatted' : formatted;
  }

  /// Formats [amountInPaise] (smallest currency unit, e.g. paise for INR)
  /// as a human-readable currency string.
  ///
  /// Example: `format(123450)` → `'₹1,234.50'`
  static String formatFromMinorUnit(
    int amountInMinorUnit, {
    String symbol = '₹',
    int minorUnitFactor = 100,
    int decimalDigits = 2,
  }) {
    final amount = amountInMinorUnit / minorUnitFactor;
    return format(amount, symbol: symbol, decimalDigits: decimalDigits);
  }

  /// Formats large amounts compactly (e.g. `1200000` → `'₹12L'`).
  static String formatCompact(double amount, {String symbol = '₹'}) {
    if (amount >= 10000000) {
      return '$symbol${(amount / 10000000).toStringAsFixed(1)}Cr';
    } else if (amount >= 100000) {
      return '$symbol${(amount / 100000).toStringAsFixed(1)}L';
    } else if (amount >= 1000) {
      return '$symbol${(amount / 1000).toStringAsFixed(1)}K';
    }
    return format(amount, symbol: symbol);
  }

  // ── Parsing ───────────────────────────────────────────────────────────────

  /// Parses a formatted currency string (e.g. `'₹1,234.50'`) to [double].
  ///
  /// Returns `null` if the string cannot be parsed.
  static double? tryParse(String value) {
    final cleaned = value.replaceAll(RegExp(r'[^\d.]'), '');
    return double.tryParse(cleaned);
  }

  // ── Arithmetic helpers ────────────────────────────────────────────────────

  /// Adds a percentage [percent] to [amount] (e.g. tax or tip).
  ///
  /// ```dart
  /// CurrencyUtils.addPercent(100.0, 18.0); // 118.0
  /// ```
  static double addPercent(double amount, double percent) =>
      amount + (amount * percent / 100);

  /// Returns the percentage [percent] of [amount].
  static double percentOf(double amount, double percent) =>
      amount * percent / 100;

  /// Rounds [amount] to the nearest [nearest] unit.
  ///
  /// ```dart
  /// CurrencyUtils.roundTo(173.0, 50.0); // 150.0
  /// ```
  static double roundTo(double amount, double nearest) =>
      (amount / nearest).round() * nearest;

  // ── Private ───────────────────────────────────────────────────────────────

  static String _formatWithThousands(int value, String sep) {
    final s = value.toString();
    if (s.length <= 3) return s;

    // Indian numbering system: last 3 then groups of 2
    final lastThree = s.substring(s.length - 3);
    final rest = s.substring(0, s.length - 3);
    final groups = <String>[];
    var i = rest.length;
    while (i > 0) {
      final start = i - 2 < 0 ? 0 : i - 2;
      groups.insert(0, rest.substring(start, i));
      i -= 2;
    }
    return '${groups.join(sep)}$sep$lastThree';
  }
}
