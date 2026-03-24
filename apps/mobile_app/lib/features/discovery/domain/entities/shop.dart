import 'package:equatable/equatable.dart';

/// Represents a shop (business) that offers services.
class Shop extends Equatable {
  const Shop({
    required this.id,
    required this.name,
    required this.address,
    required this.city,
    required this.rating,
    required this.latitude,
    required this.longitude,
    required this.imageUrls,
    required this.categoryIds,
    required this.isOpen,
    required this.reviewCount,
    this.distanceKm,
    this.phone,
    this.description,
  });

  final String id;
  final String name;
  final String address;
  final String city;
  final double rating;
  final double latitude;
  final double longitude;
  final double? distanceKm;
  final List<String> imageUrls;
  final List<String> categoryIds;
  final bool isOpen;
  final int reviewCount;
  final String? phone;
  final String? description;

  @override
  List<Object?> get props => [
        id,
        name,
        address,
        city,
        rating,
        latitude,
        longitude,
        distanceKm,
        imageUrls,
        categoryIds,
        isOpen,
        reviewCount,
        phone,
        description,
      ];
}
