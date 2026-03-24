part of 'discovery_bloc.dart';

/// Base class for all discovery BLoC events.
abstract class DiscoveryEvent extends Equatable {
  const DiscoveryEvent();

  @override
  List<Object?> get props => [];
}

/// Triggers a full-text service/shop search.
class SearchRequested extends DiscoveryEvent {
  const SearchRequested({required this.query, this.filters = const SearchFilters()});

  final String query;
  final SearchFilters filters;

  @override
  List<Object?> get props => [query, filters];
}

/// Updates the active search filters without changing the query.
class FilterChanged extends DiscoveryEvent {
  const FilterChanged(this.filters);

  final SearchFilters filters;

  @override
  List<Object?> get props => [filters];
}

/// Requests shops near the provided coordinates.
class LoadNearbyShops extends DiscoveryEvent {
  const LoadNearbyShops({required this.latitude, required this.longitude});

  final double latitude;
  final double longitude;

  @override
  List<Object?> get props => [latitude, longitude];
}

/// Loads all available service categories.
class LoadCategories extends DiscoveryEvent {
  const LoadCategories();
}

/// Loads trending / featured services.
class LoadTrending extends DiscoveryEvent {
  const LoadTrending();
}

/// Loads the full discovery home screen (categories + trending + nearby).
class LoadDiscoveryHome extends DiscoveryEvent {
  const LoadDiscoveryHome({required this.latitude, required this.longitude});

  final double latitude;
  final double longitude;

  @override
  List<Object?> get props => [latitude, longitude];
}

/// Adds or removes a shop from the user's favourites.
class ToggleFavorite extends DiscoveryEvent {
  const ToggleFavorite({required this.shopId, required this.isFavorite});

  /// The shop to toggle.
  final String shopId;

  /// Current favourite state **before** the toggle (true → remove, false → add).
  final bool isFavorite;

  @override
  List<Object?> get props => [shopId, isFavorite];
}

/// Loads the user's saved favourite shops.
class LoadFavorites extends DiscoveryEvent {
  const LoadFavorites();
}

/// Loads the user's recent search history.
class LoadRecentSearches extends DiscoveryEvent {
  const LoadRecentSearches();
}

/// Requests detailed information for a specific shop.
class ShopDetailRequested extends DiscoveryEvent {
  const ShopDetailRequested(this.shopId);

  final String shopId;

  @override
  List<Object?> get props => [shopId];
}
