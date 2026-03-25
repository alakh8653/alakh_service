import '../../domain/entities/entities.dart';

/// JSON-serialisable model for [Service].
class ServiceModel extends Service {
  const ServiceModel({
    required super.id,
    required super.name,
    required super.description,
    required super.categoryId,
    required super.shopId,
    required super.price,
    required super.durationMinutes,
    required super.isAvailable,
    super.imageUrl,
  });

  /// Constructs a [ServiceModel] from a JSON [map].
  factory ServiceModel.fromJson(Map<String, dynamic> map) {
    return ServiceModel(
      id: map['id'] as String,
      name: map['name'] as String,
      description: map['description'] as String? ?? '',
      categoryId: map['category_id'] as String,
      shopId: map['shop_id'] as String,
      price: (map['price'] as num).toDouble(),
      durationMinutes: map['duration_minutes'] as int,
      imageUrl: map['image_url'] as String?,
      isAvailable: map['is_available'] as bool? ?? true,
    );
  }

  /// Converts this model to a JSON-compatible [Map].
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category_id': categoryId,
      'shop_id': shopId,
      'price': price,
      'duration_minutes': durationMinutes,
      if (imageUrl != null) 'image_url': imageUrl,
      'is_available': isAvailable,
    };
  }

  /// Returns a copy of this model with optional field overrides.
  ServiceModel copyWith({
    String? id,
    String? name,
    String? description,
    String? categoryId,
    String? shopId,
    double? price,
    int? durationMinutes,
    String? imageUrl,
    bool? isAvailable,
  }) {
    return ServiceModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      categoryId: categoryId ?? this.categoryId,
      shopId: shopId ?? this.shopId,
      price: price ?? this.price,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      imageUrl: imageUrl ?? this.imageUrl,
      isAvailable: isAvailable ?? this.isAvailable,
    );
  }
}
