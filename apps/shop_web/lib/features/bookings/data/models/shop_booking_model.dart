/// Data model for a shop booking returned from the API.
library;

import 'package:shop_web/features/bookings/domain/entities/shop_booking.dart';

/// JSON-serializable model representing a booking record from the remote API.
class ShopBookingModel {
  const ShopBookingModel({
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

  /// Creates a [ShopBookingModel] from a JSON map returned by the API.
  factory ShopBookingModel.fromJson(Map<String, dynamic> json) {
    return ShopBookingModel(
      id: json['id'] as String,
      customerName: json['customer_name'] as String,
      customerPhone: json['customer_phone'] as String,
      customerEmail: json['customer_email'] as String,
      serviceName: json['service_name'] as String,
      servicePrice: (json['service_price'] as num).toDouble(),
      bookingDate: DateTime.parse(json['booking_date'] as String),
      timeSlot: json['time_slot'] as String,
      status: json['status'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      staffName: json['staff_name'] as String?,
      staffId: json['staff_id'] as String?,
      notes: json['notes'] as String?,
    );
  }

  final String id;
  final String customerName;
  final String customerPhone;
  final String customerEmail;
  final String serviceName;
  final double servicePrice;
  final DateTime bookingDate;

  /// Time slot string, e.g. "10:00 - 11:00".
  final String timeSlot;

  /// One of: confirmed, pending, completed, cancelled, noShow.
  final String status;
  final String? staffName;
  final String? staffId;
  final String? notes;
  final DateTime createdAt;

  /// Serialises this model back to a JSON map for API requests.
  Map<String, dynamic> toJson() => {
        'id': id,
        'customer_name': customerName,
        'customer_phone': customerPhone,
        'customer_email': customerEmail,
        'service_name': serviceName,
        'service_price': servicePrice,
        'booking_date': bookingDate.toIso8601String(),
        'time_slot': timeSlot,
        'status': status,
        'created_at': createdAt.toIso8601String(),
        if (staffName != null) 'staff_name': staffName,
        if (staffId != null) 'staff_id': staffId,
        if (notes != null) 'notes': notes,
      };

  /// Converts this model to the domain [ShopBooking] entity.
  ShopBooking toEntity() => ShopBooking(
        id: id,
        customerName: customerName,
        customerPhone: customerPhone,
        customerEmail: customerEmail,
        serviceName: serviceName,
        servicePrice: servicePrice,
        bookingDate: bookingDate,
        timeSlot: timeSlot,
        status: status,
        createdAt: createdAt,
        staffName: staffName,
        staffId: staffId,
        notes: notes,
      );
}
