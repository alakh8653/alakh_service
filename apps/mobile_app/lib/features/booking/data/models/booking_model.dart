import '../../domain/entities/entities.dart';

/// Data model for [Booking] that handles JSON serialisation.
class BookingModel extends Booking {
  const BookingModel({
    required super.id,
    required super.userId,
    required super.shopId,
    required super.serviceId,
    required super.dateTime,
    required super.status,
    required super.totalPrice,
    required super.durationMinutes,
    super.notes,
    super.staffId,
    super.staffName,
    super.shopName,
    super.serviceName,
  });

  /// Creates a [BookingModel] from a JSON [map].
  factory BookingModel.fromJson(Map<String, dynamic> map) {
    return BookingModel(
      id: map['id'] as String,
      userId: map['userId'] as String,
      shopId: map['shopId'] as String,
      serviceId: map['serviceId'] as String,
      dateTime: DateTime.parse(map['dateTime'] as String),
      status: _statusFromString(map['status'] as String),
      totalPrice: (map['totalPrice'] as num).toDouble(),
      durationMinutes: map['durationMinutes'] as int,
      notes: map['notes'] as String?,
      staffId: map['staffId'] as String?,
      staffName: map['staffName'] as String?,
      shopName: map['shopName'] as String?,
      serviceName: map['serviceName'] as String?,
    );
  }

  /// Serialises this model to a JSON-compatible map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'shopId': shopId,
      'serviceId': serviceId,
      'dateTime': dateTime.toIso8601String(),
      'status': status.name,
      'totalPrice': totalPrice,
      'durationMinutes': durationMinutes,
      if (notes != null) 'notes': notes,
      if (staffId != null) 'staffId': staffId,
      if (staffName != null) 'staffName': staffName,
      if (shopName != null) 'shopName': shopName,
      if (serviceName != null) 'serviceName': serviceName,
    };
  }

  /// Creates a copy of this model with optional overridden fields.
  @override
  BookingModel copyWith({
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
    return BookingModel(
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

  /// Converts a domain [Booking] entity into a [BookingModel].
  factory BookingModel.fromEntity(Booking booking) {
    return BookingModel(
      id: booking.id,
      userId: booking.userId,
      shopId: booking.shopId,
      serviceId: booking.serviceId,
      dateTime: booking.dateTime,
      status: booking.status,
      totalPrice: booking.totalPrice,
      durationMinutes: booking.durationMinutes,
      notes: booking.notes,
      staffId: booking.staffId,
      staffName: booking.staffName,
      shopName: booking.shopName,
      serviceName: booking.serviceName,
    );
  }

  static BookingStatus _statusFromString(String value) {
    return BookingStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => BookingStatus.pending,
    );
  }
}
