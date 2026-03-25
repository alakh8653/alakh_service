import '../../domain/entities/entities.dart';

/// JSON-serialisable model for [Category].
class CategoryModel extends Category {
  const CategoryModel({
    required super.id,
    required super.name,
    required super.iconUrl,
    required super.sortOrder,
    super.parentId,
  });

  /// Constructs a [CategoryModel] from a JSON [map].
  factory CategoryModel.fromJson(Map<String, dynamic> map) {
    return CategoryModel(
      id: map['id'] as String,
      name: map['name'] as String,
      iconUrl: map['icon_url'] as String? ?? '',
      parentId: map['parent_id'] as String?,
      sortOrder: map['sort_order'] as int? ?? 0,
    );
  }

  /// Converts this model to a JSON-compatible [Map].
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon_url': iconUrl,
      if (parentId != null) 'parent_id': parentId,
      'sort_order': sortOrder,
    };
  }

  /// Returns a copy of this model with optional field overrides.
  CategoryModel copyWith({
    String? id,
    String? name,
    String? iconUrl,
    String? parentId,
    int? sortOrder,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      iconUrl: iconUrl ?? this.iconUrl,
      parentId: parentId ?? this.parentId,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }
}
