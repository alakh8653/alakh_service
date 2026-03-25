import 'package:equatable/equatable.dart';

/// A category used to classify shops (e.g. "Salon", "Spa", "Barber").
class ShopCategory extends Equatable {
  /// Unique identifier.
  final String id;

  /// Display name of this category.
  final String name;

  /// Icon identifier or URL representing this category.
  final String icon;

  /// Optional parent category ID for hierarchical taxonomies.
  final String? parentId;

  const ShopCategory({
    required this.id,
    required this.name,
    required this.icon,
    this.parentId,
  });

  /// Creates a [ShopCategory] from a JSON map.
  factory ShopCategory.fromJson(Map<String, dynamic> json) => ShopCategory(
        id: json['id'] as String,
        name: json['name'] as String,
        icon: json['icon'] as String,
        parentId: json['parentId'] as String?,
      );

  /// Converts this instance to a JSON map.
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'icon': icon,
        if (parentId != null) 'parentId': parentId,
      };

  /// Returns a copy with optionally overridden fields.
  ShopCategory copyWith({
    String? id,
    String? name,
    String? icon,
    String? parentId,
  }) =>
      ShopCategory(
        id: id ?? this.id,
        name: name ?? this.name,
        icon: icon ?? this.icon,
        parentId: parentId ?? this.parentId,
      );

  @override
  List<Object?> get props => [id, name, icon, parentId];

  @override
  String toString() =>
      'ShopCategory(id: $id, name: $name, icon: $icon, parentId: $parentId)';
}
