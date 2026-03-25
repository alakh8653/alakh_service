/// Number extension methods for formatting and clamping.
library;

/// Helpers on [num] (applies to both [int] and [double]).
extension NumExtensions on num {
  // ---------------------------------------------------------------------------
  // Currency
  // ---------------------------------------------------------------------------

  /// Formats the number as an Indian Rupee string with commas.
  ///
  /// Example: `1234567.5.toCurrency()` → `"₹12,34,567.50"`
  String toCurrency({
    String symbol = '₹',
    int decimalPlaces = 2,
    bool showDecimals = true,
  }) {
    final formatted = showDecimals
        ? toStringAsFixed(decimalPlaces)
        : toStringAsFixed(0);
    final parts = formatted.split('.');
    final intPart = _formatIndian(parts[0]);
    final result = parts.length > 1 && showDecimals
        ? '$intPart.${parts[1]}'
        : intPart;
    return '$symbol$result';
  }

  String _formatIndian(String digits) {
    if (digits.length <= 3) return digits;
    final lastThree = digits.substring(digits.length - 3);
    final rest = digits.substring(0, digits.length - 3);
    final buffer = StringBuffer();
    for (var i = 0; i < rest.length; i++) {
      if (i != 0 && (rest.length - i) % 2 == 0) buffer.write(',');
      buffer.write(rest[i]);
    }
    return '${buffer.toString()},$lastThree';
  }

  // ---------------------------------------------------------------------------
  // Percentage
  // ---------------------------------------------------------------------------

  /// Formats the number as a percentage string.
  ///
  /// Example: `0.85.toPercentage()` → `"85.0%"`
  String toPercentage({int decimalPlaces = 1, bool multiply = true}) {
    final value = multiply ? this * 100 : this;
    return '${value.toStringAsFixed(decimalPlaces)}%';
  }

  // ---------------------------------------------------------------------------
  // File Size
  // ---------------------------------------------------------------------------

  /// Interprets the number as a byte count and formats it as a human-readable
  /// file size string.
  ///
  /// Example: `1536.toFileSize()` → `"1.5 KB"`
  String toFileSize() {
    final bytes = toDouble();
    if (bytes < 1024) return '${bytes.toStringAsFixed(0)} B';
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    }
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }

  // ---------------------------------------------------------------------------
  // Clamping / Range
  // ---------------------------------------------------------------------------

  /// Returns `true` if the value is within [[min], [max]] (inclusive).
  bool isBetween(num min, num max) => this >= min && this <= max;

  /// Returns a double between 0.0 and 1.0 representing where [this] sits
  /// within [[min], [max]].
  double normalise(num min, num max) {
    assert(max > min, 'max must be greater than min');
    return ((this - min) / (max - min)).clamp(0.0, 1.0);
  }

  // ---------------------------------------------------------------------------
  // Duration helpers
  // ---------------------------------------------------------------------------

  /// Converts [this] (seconds) to a `mm:ss` formatted string.
  ///
  /// Example: `125.secondsToMmSs` → `"02:05"`
  String get secondsToMmSs {
    final s = toInt();
    final minutes = s ~/ 60;
    final seconds = s % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}

/// Helpers specific to [int].
extension IntExtensions on int {
  /// Returns `true` when the value is even.
  bool get isEven => this % 2 == 0;

  /// Returns `true` when the value is odd.
  bool get isOdd => this % 2 != 0;

  /// Returns the ordinal suffix for the integer (st, nd, rd, th).
  String get ordinal {
    if (this >= 11 && this <= 13) return '${this}th';
    switch (this % 10) {
      case 1:
        return '${this}st';
      case 2:
        return '${this}nd';
      case 3:
        return '${this}rd';
      default:
        return '${this}th';
    }
  }
}
