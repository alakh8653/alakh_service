import 'package:equatable/equatable.dart';

/// Encapsulates all filters that can be applied to a service/shop search.
class SearchFilters extends Equatable {
  const SearchFilters({
    this.minPrice,
    this.maxPrice,
    this.minRating,
    this.maxDistanceKm,
    this.categoryId,
    this.sortBy = 'relevance',
    this.openNow = false,
  });

  final double? minPrice;
  final double? maxPrice;
  final double? minRating;
  final double? maxDistanceKm;
  final String? categoryId;

  /// One of: `'relevance'`, `'rating'`, `'distance'`, `'price'`.
  final String sortBy;
  final bool openNow;

  /// Returns a copy of this [SearchFilters] with the given fields replaced.
  SearchFilters copyWith({
    double? minPrice,
    double? maxPrice,
    double? minRating,
    double? maxDistanceKm,
    String? categoryId,
    String? sortBy,
    bool? openNow,
  }) {
    return SearchFilters(
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      minRating: minRating ?? this.minRating,
      maxDistanceKm: maxDistanceKm ?? this.maxDistanceKm,
      categoryId: categoryId ?? this.categoryId,
      sortBy: sortBy ?? this.sortBy,
      openNow: openNow ?? this.openNow,
    );
  }

  @override
  List<Object?> get props =>
      [minPrice, maxPrice, minRating, maxDistanceKm, categoryId, sortBy, openNow];
}
