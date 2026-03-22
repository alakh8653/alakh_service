import '../../domain/entities/entities.dart';

/// JSON-serialisable model for [Shop].
class ShopModel extends Shop {
  const ShopModel({
    required super.id,
    required super.name,
    required super.address,
    required super.city,
    required super.rating,
    required super.latitude,
    required super.longitude,
    required super.imageUrls,
    required super.categoryIds,
    required super.isOpen,
    required super.reviewCount,
    super.distanceKm,
    super.phone,
    super.description,
  });

  /// Constructs a [ShopModel] from a JSON [map].
  factory ShopModel.fromJson(Map<String, dynamic> map) {
    return ShopModel(
      id: map['id'] as String,
      name: map['name'] as String,
      address: map['address'] as String,
      city: map['city'] as String,
      rating: (map['rating'] as num).toDouble(),
      latitude: (map['latitude'] as num).toDouble(),
      longitude: (map['longitude'] as num).toDouble(),
      distanceKm: map['distance_km'] != null
          ? (map['distance_km'] as num).toDouble()
          : null,
      imageUrls: List<String>.from(map['image_urls'] as List? ?? []),
      categoryIds: List<String>.from(map['category_ids'] as List? ?? []),
      isOpen: map['is_open'] as bool? ?? false,
      reviewCount: map['review_count'] as int? ?? 0,
      phone: map['phone'] as String?,
      description: map['description'] as String?,
    );
  }

  /// Converts this model to a JSON-compatible [Map].
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'city': city,
      'rating': rating,
      'latitude': latitude,
      'longitude': longitude,
      if (distanceKm != null) 'distance_km': distanceKm,
      'image_urls': imageUrls,
      'category_ids': categoryIds,
      'is_open': isOpen,
      'review_count': reviewCount,
      if (phone != null) 'phone': phone,
      if (description != null) 'description': description,
    };
  }

  /// Returns a copy of this model with optional field overrides.
  ShopModel copyWith({
    String? id,
    String? name,
    String? address,
    String? city,
    double? rating,
    double? latitude,
    double? longitude,
    double? distanceKm,
    List<String>? imageUrls,
    List<String>? categoryIds,
    bool? isOpen,
    int? reviewCount,
    String? phone,
    String? description,
  }) {
    return ShopModel(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      city: city ?? this.city,
      rating: rating ?? this.rating,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      distanceKm: distanceKm ?? this.distanceKm,
      imageUrls: imageUrls ?? this.imageUrls,
      categoryIds: categoryIds ?? this.categoryIds,
      isOpen: isOpen ?? this.isOpen,
      reviewCount: reviewCount ?? this.reviewCount,
      phone: phone ?? this.phone,
      description: description ?? this.description,
    );
  }
}
