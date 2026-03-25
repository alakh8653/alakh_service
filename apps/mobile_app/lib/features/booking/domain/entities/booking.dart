import 'package:equatable/equatable.dart';
import 'booking_status.dart';

/// Domain entity representing a single booking appointment.
class Booking extends Equatable {
  /// Unique identifier of the booking.
  final String id;

  /// Identifier of the user who made the booking.
  final String userId;

  /// Identifier of the shop where the service is booked.
  final String shopId;

  /// Identifier of the service being booked.
  final String serviceId;

  /// Scheduled date and time of the appointment.
  final DateTime dateTime;

  /// Current lifecycle status of the booking.
  final BookingStatus status;

  /// Total price charged for the booking.
  final double totalPrice;

  /// Duration of the service in minutes.
  final int durationMinutes;

  /// Optional notes left by the user.
  final String? notes;

  /// Optional identifier of the assigned staff member.
  final String? staffId;

  /// Optional display name of the assigned staff member.
  final String? staffName;

  /// Display name of the shop.
  final String? shopName;

  /// Display name of the service.
  final String? serviceName;

  const Booking({
    required this.id,
    required this.userId,
    required this.shopId,
    required this.serviceId,
    required this.dateTime,
    required this.status,
    required this.totalPrice,
    required this.durationMinutes,
    this.notes,
    this.staffId,
    this.staffName,
    this.shopName,
    this.serviceName,
  });

  @override
  List<Object?> get props => [
        id,
        userId,
        shopId,
        serviceId,
        dateTime,
        status,
        totalPrice,
        durationMinutes,
        notes,
        staffId,
        staffName,
        shopName,
        serviceName,
      ];

  /// Creates a copy of this booking with optional overridden fields.
  Booking copyWith({
    String? id,
    String? userId,
    String? shopId,
    String? serviceId,
    DateTime? dateTime,
    BookingStatus? status,
    double? totalPrice,
    int? durationMinutes,
    String? notes,
    String? staffId,
    String? staffName,
    String? shopName,
    String? serviceName,
  }) {
    return Booking(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      shopId: shopId ?? this.shopId,
      serviceId: serviceId ?? this.serviceId,
      dateTime: dateTime ?? this.dateTime,
      status: status ?? this.status,
      totalPrice: totalPrice ?? this.totalPrice,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      notes: notes ?? this.notes,
      staffId: staffId ?? this.staffId,
      staffName: staffName ?? this.staffName,
      shopName: shopName ?? this.shopName,
      serviceName: serviceName ?? this.serviceName,
    );
  }
}
