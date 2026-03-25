import 'package:equatable/equatable.dart';

/// Represents a service offered by a shop.
class Service extends Equatable {
  const Service({
    required this.id,
    required this.name,
    required this.description,
    required this.categoryId,
    required this.shopId,
    required this.price,
    required this.durationMinutes,
    required this.isAvailable,
    this.imageUrl,
  });

  final String id;
  final String name;
  final String description;
  final String categoryId;
  final String shopId;
  final double price;
  final int durationMinutes;
  final String? imageUrl;
  final bool isAvailable;

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        categoryId,
        shopId,
        price,
        durationMinutes,
        imageUrl,
        isAvailable,
      ];
}
