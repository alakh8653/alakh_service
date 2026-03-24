import '../../domain/entities/entities.dart';

/// JSON-serialisable model for [SearchFilters].
class FilterModel extends SearchFilters {
  const FilterModel({
    super.minPrice,
    super.maxPrice,
    super.minRating,
    super.maxDistanceKm,
    super.categoryId,
    super.sortBy,
    super.openNow,
  });

  /// Constructs a [FilterModel] from a JSON [map].
  factory FilterModel.fromJson(Map<String, dynamic> map) {
    return FilterModel(
      minPrice:
          map['min_price'] != null ? (map['min_price'] as num).toDouble() : null,
      maxPrice:
          map['max_price'] != null ? (map['max_price'] as num).toDouble() : null,
      minRating: map['min_rating'] != null
          ? (map['min_rating'] as num).toDouble()
          : null,
      maxDistanceKm: map['max_distance_km'] != null
          ? (map['max_distance_km'] as num).toDouble()
          : null,
      categoryId: map['category_id'] as String?,
      sortBy: map['sort_by'] as String? ?? 'relevance',
      openNow: map['open_now'] as bool? ?? false,
    );
  }

  /// Converts this model to a JSON-compatible [Map].
  Map<String, dynamic> toJson() {
    return {
      if (minPrice != null) 'min_price': minPrice,
      if (maxPrice != null) 'max_price': maxPrice,
      if (minRating != null) 'min_rating': minRating,
      if (maxDistanceKm != null) 'max_distance_km': maxDistanceKm,
      if (categoryId != null) 'category_id': categoryId,
      'sort_by': sortBy,
      'open_now': openNow,
    };
  }

  @override
  FilterModel copyWith({
    double? minPrice,
    double? maxPrice,
    double? minRating,
    double? maxDistanceKm,
    String? categoryId,
    String? sortBy,
    bool? openNow,
  }) {
    return FilterModel(
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      minRating: minRating ?? this.minRating,
      maxDistanceKm: maxDistanceKm ?? this.maxDistanceKm,
      categoryId: categoryId ?? this.categoryId,
      sortBy: sortBy ?? this.sortBy,
      openNow: openNow ?? this.openNow,
    );
  }
}
