import 'package:intl/intl.dart';

/// Utility class for formatting and parsing currency values.
class CurrencyFormatter {
  CurrencyFormatter._();

  /// Formats [amount] as a currency string.
  ///
  /// Defaults to Indian Rupee (`INR`) with locale `en_IN`.
  ///
  /// Examples:
  /// - `1234.5` → `"₹1,234.50"`
  static String formatCurrency(
    double amount, {
    String currency = 'INR',
    String? locale,
  }) {
    final resolvedLocale = locale ?? (currency == 'INR' ? 'en_IN' : 'en_US');
    final formatter = NumberFormat.currency(
      locale: resolvedLocale,
      name: currency,
      symbol: _symbolFor(currency),
    );
    return formatter.format(amount);
  }

  /// Formats [amount] in compact notation.
  ///
  /// Examples:
  /// - `1200` → `"1.2K"`
  /// - `1_500_000` → `"1.5M"`
  /// - `2_300_000_000` → `"2.3B"`
  static String formatCompact(double amount) {
    if (amount.abs() >= 1e9) {
      return '${(amount / 1e9).toStringAsFixed(1)}B';
    }
    if (amount.abs() >= 1e6) {
      return '${(amount / 1e6).toStringAsFixed(1)}M';
    }
    if (amount.abs() >= 1e3) {
      return '${(amount / 1e3).toStringAsFixed(1)}K';
    }
    return amount.toStringAsFixed(2);
  }

  /// Parses a formatted currency string and returns the numeric [double] value.
  ///
  /// Strips all characters except digits, periods, and minus signs.
  ///
  /// Returns `0.0` if [value] cannot be parsed.
  static double parseCurrency(String value) {
    final cleaned = value.replaceAll(RegExp(r'[^\d.\-]'), '');
    return double.tryParse(cleaned) ?? 0.0;
  }

  static String _symbolFor(String currency) {
    const symbols = <String, String>{
      'INR': '₹',
      'USD': '\$',
      'EUR': '€',
      'GBP': '£',
      'JPY': '¥',
    };
    return symbols[currency] ?? currency;
  }
}
