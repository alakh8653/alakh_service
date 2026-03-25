import 'package:equatable/equatable.dart';

import 'payment_method_type.dart';
import 'payment_status.dart';

/// Represents a payment transaction linked to a booking.
class Payment extends Equatable {
  /// Unique identifier for this transaction.
  final String id;

  /// ID of the booking this payment covers.
  final String bookingId;

  /// Amount charged for this transaction.
  final double amount;

  /// ISO 4217 currency code (e.g. `'INR'`).
  final String currency;

  /// Payment method used by the customer.
  final PaymentMethodType method;

  /// Current state of this payment transaction.
  final PaymentStatus status;

  /// UTC timestamp when the payment record was created.
  final DateTime createdAt;

  const Payment({
    required this.id,
    required this.bookingId,
    required this.amount,
    required this.currency,
    required this.method,
    required this.status,
    required this.createdAt,
  });

  /// Creates a [Payment] from a JSON map.
  factory Payment.fromJson(Map<String, dynamic> json) => Payment(
        id: json['id'] as String,
        bookingId: json['bookingId'] as String,
        amount: (json['amount'] as num).toDouble(),
        currency: json['currency'] as String,
        method: PaymentMethodType.fromJson(json['method'] as String),
        status: PaymentStatus.fromJson(json['status'] as String),
        createdAt: DateTime.parse(json['createdAt'] as String),
      );

  /// Converts this instance to a JSON map.
  Map<String, dynamic> toJson() => {
        'id': id,
        'bookingId': bookingId,
        'amount': amount,
        'currency': currency,
        'method': method.toJson(),
        'status': status.toJson(),
        'createdAt': createdAt.toIso8601String(),
      };

  /// Returns a copy with optionally overridden fields.
  Payment copyWith({
    String? id,
    String? bookingId,
    double? amount,
    String? currency,
    PaymentMethodType? method,
    PaymentStatus? status,
    DateTime? createdAt,
  }) =>
      Payment(
        id: id ?? this.id,
        bookingId: bookingId ?? this.bookingId,
        amount: amount ?? this.amount,
        currency: currency ?? this.currency,
        method: method ?? this.method,
        status: status ?? this.status,
        createdAt: createdAt ?? this.createdAt,
      );

  @override
  List<Object?> get props =>
      [id, bookingId, amount, currency, method, status, createdAt];

  @override
  String toString() =>
      'Payment(id: $id, bookingId: $bookingId, amount: $amount, '
      'currency: $currency, method: $method, status: $status, createdAt: $createdAt)';
}
