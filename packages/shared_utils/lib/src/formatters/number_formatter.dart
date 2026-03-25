import 'package:intl/intl.dart';

/// Utility class for formatting numeric values into human-readable strings.
class NumberFormatter {
  NumberFormatter._();

  /// Formats [value] as a decimal number with [decimals] fractional digits.
  ///
  /// Example: `formatDecimal(1234567.891)` → `"1,234,567.89"`
  static String formatDecimal(double value, {int decimals = 2}) =>
      NumberFormat('#,##0.${'0' * decimals}').format(value);

  /// Formats [value] as a percentage string.
  ///
  /// Example: `formatPercentage(0.856)` → `"85.6%"`
  static String formatPercentage(double value, {int decimals = 1}) {
    final pct = value > 1 ? value : value * 100;
    return '${pct.toStringAsFixed(decimals)}%';
  }

  /// Converts a byte count into a human-readable file size string.
  ///
  /// Examples:
  /// - `1024` → `"1.0 KB"`
  /// - `1_572_864` → `"1.5 MB"`
  static String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    }
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  /// Formats [value] in compact notation.
  ///
  /// Examples:
  /// - `1200` → `"1.2K"`
  /// - `2_500_000` → `"2.5M"`
  /// - `3_100_000_000` → `"3.1B"`
  static String formatCompact(num value) {
    final abs = value.abs();
    if (abs >= 1e9) return '${(value / 1e9).toStringAsFixed(1)}B';
    if (abs >= 1e6) return '${(value / 1e6).toStringAsFixed(1)}M';
    if (abs >= 1e3) return '${(value / 1e3).toStringAsFixed(1)}K';
    return value.toString();
  }
}
