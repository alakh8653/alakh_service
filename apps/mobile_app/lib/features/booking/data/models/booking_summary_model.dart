/// Lightweight summary of a booking used in list views.
class BookingSummaryModel {
  final String id;
  final String shopName;
  final String serviceName;
  final DateTime dateTime;
  final String status;
  final double totalPrice;

  const BookingSummaryModel({
    required this.id,
    required this.shopName,
    required this.serviceName,
    required this.dateTime,
    required this.status,
    required this.totalPrice,
  });

  /// Creates a [BookingSummaryModel] from a JSON [map].
  factory BookingSummaryModel.fromJson(Map<String, dynamic> map) {
    return BookingSummaryModel(
      id: map['id'] as String,
      shopName: map['shopName'] as String,
      serviceName: map['serviceName'] as String,
      dateTime: DateTime.parse(map['dateTime'] as String),
      status: map['status'] as String,
      totalPrice: (map['totalPrice'] as num).toDouble(),
    );
  }

  /// Serialises this summary to a JSON-compatible map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'shopName': shopName,
      'serviceName': serviceName,
      'dateTime': dateTime.toIso8601String(),
      'status': status,
      'totalPrice': totalPrice,
    };
  }

  /// Creates a copy of this summary with optional overridden fields.
  BookingSummaryModel copyWith({
    String? id,
    String? shopName,
    String? serviceName,
    DateTime? dateTime,
    String? status,
    double? totalPrice,
  }) {
    return BookingSummaryModel(
      id: id ?? this.id,
      shopName: shopName ?? this.shopName,
      serviceName: serviceName ?? this.serviceName,
      dateTime: dateTime ?? this.dateTime,
      status: status ?? this.status,
      totalPrice: totalPrice ?? this.totalPrice,
    );
  }
}
