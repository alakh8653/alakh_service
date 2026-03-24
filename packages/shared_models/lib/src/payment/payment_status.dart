/// Represents the current state of a payment transaction.
enum PaymentStatus {
  pending,
  processing,
  completed,
  failed,
  refunded,
  cancelled;

  /// Serializes this status to a JSON string.
  String toJson() => name;

  /// Deserializes a status from a JSON string.
  /// Falls back to [PaymentStatus.pending] if the value is unrecognized.
  static PaymentStatus fromJson(String value) => PaymentStatus.values
      .firstWhere((e) => e.name == value, orElse: () => PaymentStatus.pending);
}
