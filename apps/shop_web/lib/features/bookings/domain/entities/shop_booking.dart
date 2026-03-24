/// Domain entity representing a single shop booking.
library;

import 'package:equatable/equatable.dart';

/// Immutable domain object for a booking record.
///
/// [status] is one of: `confirmed`, `pending`, `completed`,
/// `cancelled`, `noShow`.
class ShopBooking extends Equatable {
  const ShopBooking({
    required this.id,
    required this.customerName,
    required this.customerPhone,
    required this.customerEmail,
    required this.serviceName,
    required this.servicePrice,
    required this.bookingDate,
    required this.timeSlot,
    required this.status,
    required this.createdAt,
    this.staffName,
    this.staffId,
    this.notes,
  });

  final String id;
  final String customerName;
  final String customerPhone;
  final String customerEmail;
  final String serviceName;
  final double servicePrice;
  final DateTime bookingDate;

  /// Human-readable time slot string, e.g. "10:00 - 11:00".
  final String timeSlot;

  /// Booking lifecycle status.
  final String status;
  final String? staffName;
  final String? staffId;
  final String? notes;
  final DateTime createdAt;

  /// Returns `true` when this booking can still be confirmed.
  bool get isPending => status == 'pending';

  /// Returns `true` when the booking was attended.
  bool get isCompleted => status == 'completed';

  /// Returns `true` when this booking has been cancelled.
  bool get isCancelled => status == 'cancelled';

  /// Returns `true` when the customer did not show up.
  bool get isNoShow => status == 'noShow';

  /// Returns `true` when this booking is confirmed.
  bool get isConfirmed => status == 'confirmed';

  /// Returns a copy of this entity with the given fields replaced.
  ShopBooking copyWith({
    String? id,
    String? customerName,
    String? customerPhone,
    String? customerEmail,
    String? serviceName,
    double? servicePrice,
    DateTime? bookingDate,
    String? timeSlot,
    String? status,
    String? staffName,
    String? staffId,
    String? notes,
    DateTime? createdAt,
  }) {
    return ShopBooking(
      id: id ?? this.id,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      customerEmail: customerEmail ?? this.customerEmail,
      serviceName: serviceName ?? this.serviceName,
      servicePrice: servicePrice ?? this.servicePrice,
      bookingDate: bookingDate ?? this.bookingDate,
      timeSlot: timeSlot ?? this.timeSlot,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      staffName: staffName ?? this.staffName,
      staffId: staffId ?? this.staffId,
      notes: notes ?? this.notes,
    );
  }

  @override
  List<Object?> get props => [
        id,
        customerName,
        customerPhone,
        customerEmail,
        serviceName,
        servicePrice,
        bookingDate,
        timeSlot,
        status,
        staffName,
        staffId,
        notes,
        createdAt,
      ];
}
