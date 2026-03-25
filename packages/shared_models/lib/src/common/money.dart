import 'package:equatable/equatable.dart';

/// An immutable value object representing a monetary amount in a specific currency.
///
/// Arithmetic operations return new [Money] instances; currency mismatches throw
/// [ArgumentError].
class Money extends Equatable {
  /// The numeric amount (e.g. `199.99`).
  final double amount;

  /// The ISO 4217 currency code (e.g. `'INR'`, `'USD'`).
  final String currency;

  const Money({required this.amount, required this.currency});

  /// Convenience constructor for zero in the given [currency].
  const Money.zero(String currency) : this(amount: 0, currency: currency);

  /// Creates a [Money] instance from a JSON map.
  factory Money.fromJson(Map<String, dynamic> json) => Money(
        amount: (json['amount'] as num).toDouble(),
        currency: json['currency'] as String,
      );

  /// Converts this instance to a JSON map.
  Map<String, dynamic> toJson() => {
        'amount': amount,
        'currency': currency,
      };

  /// Returns a copy with optionally overridden fields.
  Money copyWith({double? amount, String? currency}) => Money(
        amount: amount ?? this.amount,
        currency: currency ?? this.currency,
      );

  /// Adds [other] to this money value.
  ///
  /// Throws [ArgumentError] if currencies differ.
  Money add(Money other) {
    _assertSameCurrency(other);
    return Money(amount: amount + other.amount, currency: currency);
  }

  /// Subtracts [other] from this money value.
  ///
  /// Throws [ArgumentError] if currencies differ.
  Money subtract(Money other) {
    _assertSameCurrency(other);
    return Money(amount: amount - other.amount, currency: currency);
  }

  /// Multiplies this money value by a scalar [factor].
  Money multiply(double factor) =>
      Money(amount: amount * factor, currency: currency);

  /// Returns a human-readable representation such as `₹ 199.00`.
  String format({int decimalDigits = 2}) {
    final symbol = _currencySymbol(currency);
    return '$symbol ${amount.toStringAsFixed(decimalDigits)}';
  }

  void _assertSameCurrency(Money other) {
    if (currency != other.currency) {
      throw ArgumentError(
          'Cannot operate on different currencies: $currency vs ${other.currency}');
    }
  }

  static String _currencySymbol(String code) => switch (code.toUpperCase()) {
        'INR' => '₹',
        'USD' => '\$',
        'EUR' => '€',
        'GBP' => '£',
        _ => code,
      };

  @override
  List<Object?> get props => [amount, currency];

  @override
  String toString() => 'Money(amount: $amount, currency: $currency)';
}
