import 'package:equatable/equatable.dart';

import '../location/address.dart';
import '../location/coordinates.dart';

/// Represents a service shop (salon, spa, barbershop, etc.).
class Shop extends Equatable {
  /// Unique identifier.
  final String id;

  /// Trading / display name of the shop.
  final String name;

  /// Detailed description of services offered.
  final String description;

  /// Physical address of the shop.
  final Address address;

  /// GPS coordinates used for proximity searches.
  final Coordinates coordinates;

  /// Aggregate customer rating, typically in the range 0–5.
  final double rating;

  /// List of image URLs showcasing the shop.
  final List<String> images;

  /// List of category IDs this shop belongs to.
  final List<String> categories;

  /// Whether the shop is currently accepting bookings.
  final bool isActive;

  /// ID of the [User] who owns this shop.
  final String ownerId;

  const Shop({
    required this.id,
    required this.name,
    required this.description,
    required this.address,
    required this.coordinates,
    required this.rating,
    required this.images,
    required this.categories,
    required this.isActive,
    required this.ownerId,
  });

  /// Creates a [Shop] from a JSON map.
  factory Shop.fromJson(Map<String, dynamic> json) => Shop(
        id: json['id'] as String,
        name: json['name'] as String,
        description: json['description'] as String,
        address: Address.fromJson(json['address'] as Map<String, dynamic>),
        coordinates:
            Coordinates.fromJson(json['coordinates'] as Map<String, dynamic>),
        rating: (json['rating'] as num).toDouble(),
        images:
            (json['images'] as List<dynamic>).map((e) => e as String).toList(),
        categories: (json['categories'] as List<dynamic>)
            .map((e) => e as String)
            .toList(),
        isActive: json['isActive'] as bool,
        ownerId: json['ownerId'] as String,
      );

  /// Converts this instance to a JSON map.
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'address': address.toJson(),
        'coordinates': coordinates.toJson(),
        'rating': rating,
        'images': images,
        'categories': categories,
        'isActive': isActive,
        'ownerId': ownerId,
      };

  /// Returns a copy with optionally overridden fields.
  Shop copyWith({
    String? id,
    String? name,
    String? description,
    Address? address,
    Coordinates? coordinates,
    double? rating,
    List<String>? images,
    List<String>? categories,
    bool? isActive,
    String? ownerId,
  }) =>
      Shop(
        id: id ?? this.id,
        name: name ?? this.name,
        description: description ?? this.description,
        address: address ?? this.address,
        coordinates: coordinates ?? this.coordinates,
        rating: rating ?? this.rating,
        images: images ?? this.images,
        categories: categories ?? this.categories,
        isActive: isActive ?? this.isActive,
        ownerId: ownerId ?? this.ownerId,
      );

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        address,
        coordinates,
        rating,
        images,
        categories,
        isActive,
        ownerId,
      ];

  @override
  String toString() =>
      'Shop(id: $id, name: $name, rating: $rating, isActive: $isActive, ownerId: $ownerId)';
}
