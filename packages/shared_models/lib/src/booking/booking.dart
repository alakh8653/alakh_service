import 'package:equatable/equatable.dart';

import 'booking_status.dart';

/// Represents a customer's appointment at a shop.
class Booking extends Equatable {
  /// Unique identifier.
  final String id;

  /// ID of the customer who made the booking.
  final String userId;

  /// ID of the shop where the service will be performed.
  final String shopId;

  /// ID of the service booked.
  final String serviceId;

  /// Optional ID of the staff member assigned to this booking.
  final String? staffId;

  /// Scheduled UTC date and time of the appointment.
  final DateTime dateTime;

  /// Expected duration of the appointment in minutes.
  final int durationMinutes;

  /// Current lifecycle status of the booking.
  final BookingStatus status;

  /// Total amount charged for this booking.
  final double totalPrice;

  /// Optional customer notes or special requests.
  final String? notes;

  const Booking({
    required this.id,
    required this.userId,
    required this.shopId,
    required this.serviceId,
    this.staffId,
    required this.dateTime,
    required this.durationMinutes,
    required this.status,
    required this.totalPrice,
    this.notes,
  });

  /// Creates a [Booking] from a JSON map.
  factory Booking.fromJson(Map<String, dynamic> json) => Booking(
        id: json['id'] as String,
        userId: json['userId'] as String,
        shopId: json['shopId'] as String,
        serviceId: json['serviceId'] as String,
        staffId: json['staffId'] as String?,
        dateTime: DateTime.parse(json['dateTime'] as String),
        durationMinutes: json['durationMinutes'] as int,
        status: BookingStatus.fromJson(json['status'] as String),
        totalPrice: (json['totalPrice'] as num).toDouble(),
        notes: json['notes'] as String?,
      );

  /// Converts this instance to a JSON map.
  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'shopId': shopId,
        'serviceId': serviceId,
        if (staffId != null) 'staffId': staffId,
        'dateTime': dateTime.toIso8601String(),
        'durationMinutes': durationMinutes,
        'status': status.toJson(),
        'totalPrice': totalPrice,
        if (notes != null) 'notes': notes,
      };

  /// Returns a copy with optionally overridden fields.
  Booking copyWith({
    String? id,
    String? userId,
    String? shopId,
    String? serviceId,
    String? staffId,
    DateTime? dateTime,
    int? durationMinutes,
    BookingStatus? status,
    double? totalPrice,
    String? notes,
  }) =>
      Booking(
        id: id ?? this.id,
        userId: userId ?? this.userId,
        shopId: shopId ?? this.shopId,
        serviceId: serviceId ?? this.serviceId,
        staffId: staffId ?? this.staffId,
        dateTime: dateTime ?? this.dateTime,
        durationMinutes: durationMinutes ?? this.durationMinutes,
        status: status ?? this.status,
        totalPrice: totalPrice ?? this.totalPrice,
        notes: notes ?? this.notes,
      );

  @override
  List<Object?> get props => [
        id,
        userId,
        shopId,
        serviceId,
        staffId,
        dateTime,
        durationMinutes,
        status,
        totalPrice,
        notes,
      ];

  @override
  String toString() =>
      'Booking(id: $id, userId: $userId, shopId: $shopId, '
      'serviceId: $serviceId, staffId: $staffId, dateTime: $dateTime, '
      'durationMinutes: $durationMinutes, status: $status, '
      'totalPrice: $totalPrice, notes: $notes)';
}
