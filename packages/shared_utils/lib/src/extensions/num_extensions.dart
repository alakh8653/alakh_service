import '../formatters/currency_formatter.dart';
import '../formatters/number_formatter.dart';

/// Convenient extension methods on [num].
extension NumExtensions on num {
  /// Formats this value as a currency string.
  ///
  /// Defaults to Indian Rupee (`INR`).
  ///
  /// Example: `1234.5.toPrice()` → `"₹1,234.50"`
  String toPrice({String currency = 'INR'}) =>
      CurrencyFormatter.formatCurrency(toDouble(), currency: currency);

  /// Formats this value in compact notation.
  ///
  /// Example: `1_500_000.toCompact` → `"1.5M"`
  String get toCompact => NumberFormatter.formatCompact(this);

  /// Formats this value as a percentage with [decimals] fractional digits.
  ///
  /// Values greater than `1` are used as-is; values ≤ `1` are multiplied
  /// by 100 first.
  ///
  /// Example: `0.856.toPercentage()` → `"85.6%"`
  String toPercentage({int decimals = 1}) =>
      NumberFormatter.formatPercentage(toDouble(), decimals: decimals);

  /// Clamps this value to the range `[0.0, 1.0]`.
  double get clamp01 => clamp(0.0, 1.0).toDouble();

  /// Returns `true` when this value is within the inclusive range `[min, max]`.
  bool isInRange(num min, num max) => this >= min && this <= max;
}
