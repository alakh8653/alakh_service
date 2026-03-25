/// Payload sent to the API when creating a booking.
class BookingRequestModel {
  final String userId;
  final String shopId;
  final String serviceId;
  final String timeSlotId;
  final String? staffId;
  final String? notes;

  const BookingRequestModel({
    required this.userId,
    required this.shopId,
    required this.serviceId,
    required this.timeSlotId,
    this.staffId,
    this.notes,
  });

  /// Serialises the request to a JSON-compatible map.
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'shopId': shopId,
      'serviceId': serviceId,
      'timeSlotId': timeSlotId,
      if (staffId != null) 'staffId': staffId,
      if (notes != null) 'notes': notes,
    };
  }
}
