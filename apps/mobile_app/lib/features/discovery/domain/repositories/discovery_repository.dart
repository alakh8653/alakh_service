import 'package:dartz/dartz.dart';

import '../../core/failures.dart';
import '../entities/entities.dart';
import 'params.dart';

/// Abstract contract for the discovery data layer.
abstract class DiscoveryRepository {
  /// Searches services/shops matching [params].
  Future<Either<Failure, SearchResult>> searchServices(SearchParams params);

  /// Returns shops near the location described by [params].
  Future<Either<Failure, List<Shop>>> getNearbyShops(LocationParams params);

  /// Returns all top-level and sub-categories.
  Future<Either<Failure, List<Category>>> getCategories();

  /// Returns full details for the shop with [shopId].
  Future<Either<Failure, Shop>> getShopDetails(String shopId);

  /// Returns a curated list of trending services.
  Future<Either<Failure, List<Service>>> getTrendingServices();

  /// Adds the shop identified by [shopId] to the current user's favourites.
  Future<Either<Failure, void>> addToFavorites(String shopId);

  /// Removes the shop identified by [shopId] from the current user's favourites.
  Future<Either<Failure, void>> removeFromFavorites(String shopId);

  /// Returns the current user's favourite shops.
  Future<Either<Failure, List<Shop>>> getFavorites();

  /// Returns the user's most recent search queries.
  Future<Either<Failure, List<String>>> getRecentSearches();

  /// Persists [query] to the recent-searches history.
  Future<Either<Failure, void>> saveSearch(String query);
}

// ── Parameter objects ─────────────────────────────────────────────────────────

/// Parameters for a full-text service/shop search.
class SearchParams {
  const SearchParams({required this.query, this.filters = const SearchFilters()});

  final String query;
  final SearchFilters filters;
}

/// Parameters for a proximity-based shop lookup.
class LocationParams {
  const LocationParams({
    required this.latitude,
    required this.longitude,
    this.radiusKm = 10.0,
  });

  final double latitude;
  final double longitude;
  final double radiusKm;
}

/// The result returned by a search operation.
class SearchResult {
  const SearchResult({
    required this.shops,
    required this.services,
    required this.totalCount,
  });

  final List<Shop> shops;
  final List<Service> services;
  final int totalCount;
}
