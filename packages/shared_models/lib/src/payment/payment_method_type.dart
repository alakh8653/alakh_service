/// Represents the payment method used for a transaction.
enum PaymentMethodType {
  card,
  upi,
  wallet,
  cash,
  netBanking;

  /// Serializes this payment method to a JSON string.
  String toJson() => name;

  /// Deserializes a payment method from a JSON string.
  /// Falls back to [PaymentMethodType.cash] if the value is unrecognized.
  static PaymentMethodType fromJson(String value) =>
      PaymentMethodType.values.firstWhere((e) => e.name == value,
          orElse: () => PaymentMethodType.cash);
}
