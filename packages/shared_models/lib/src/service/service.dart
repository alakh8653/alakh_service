import 'package:equatable/equatable.dart';

/// Represents a service offered by a shop (e.g. "Men's Haircut", "Facial").
class Service extends Equatable {
  /// Unique identifier.
  final String id;

  /// Display name of the service.
  final String name;

  /// Detailed description of what the service includes.
  final String description;

  /// Price of the service in the shop's base currency.
  final double price;

  /// Estimated duration of the service in minutes.
  final int durationMinutes;

  /// ID of the category this service belongs to.
  final String categoryId;

  /// ID of the shop that offers this service.
  final String shopId;

  /// Whether the service is currently available for booking.
  final bool isActive;

  const Service({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.durationMinutes,
    required this.categoryId,
    required this.shopId,
    required this.isActive,
  });

  /// Creates a [Service] from a JSON map.
  factory Service.fromJson(Map<String, dynamic> json) => Service(
        id: json['id'] as String,
        name: json['name'] as String,
        description: json['description'] as String,
        price: (json['price'] as num).toDouble(),
        durationMinutes: json['durationMinutes'] as int,
        categoryId: json['categoryId'] as String,
        shopId: json['shopId'] as String,
        isActive: json['isActive'] as bool,
      );

  /// Converts this instance to a JSON map.
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'price': price,
        'durationMinutes': durationMinutes,
        'categoryId': categoryId,
        'shopId': shopId,
        'isActive': isActive,
      };

  /// Returns a copy with optionally overridden fields.
  Service copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    int? durationMinutes,
    String? categoryId,
    String? shopId,
    bool? isActive,
  }) =>
      Service(
        id: id ?? this.id,
        name: name ?? this.name,
        description: description ?? this.description,
        price: price ?? this.price,
        durationMinutes: durationMinutes ?? this.durationMinutes,
        categoryId: categoryId ?? this.categoryId,
        shopId: shopId ?? this.shopId,
        isActive: isActive ?? this.isActive,
      );

  @override
  List<Object?> get props =>
      [id, name, description, price, durationMinutes, categoryId, shopId, isActive];

  @override
  String toString() =>
      'Service(id: $id, name: $name, price: $price, '
      'durationMinutes: $durationMinutes, shopId: $shopId, isActive: $isActive)';
}
