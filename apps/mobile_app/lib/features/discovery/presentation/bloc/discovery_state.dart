part of 'discovery_bloc.dart';

/// Base class for all discovery BLoC states.
abstract class DiscoveryState extends Equatable {
  const DiscoveryState();

  @override
  List<Object?> get props => [];
}

/// The initial state before any event is dispatched.
class DiscoveryInitial extends DiscoveryState {
  const DiscoveryInitial();
}

/// Indicates that a data-loading operation is in progress.
class DiscoveryLoading extends DiscoveryState {
  const DiscoveryLoading();
}

/// Emitted when the home screen data has loaded successfully.
class DiscoveryHomeLoaded extends DiscoveryState {
  const DiscoveryHomeLoaded({
    required this.categories,
    required this.trendingServices,
    required this.nearbyShops,
    this.recentSearches = const [],
  });

  final List<Category> categories;
  final List<Service> trendingServices;
  final List<Shop> nearbyShops;
  final List<String> recentSearches;

  @override
  List<Object?> get props =>
      [categories, trendingServices, nearbyShops, recentSearches];
}

/// Emitted when a search completes successfully.
class SearchResultsLoaded extends DiscoveryState {
  const SearchResultsLoaded({
    required this.result,
    required this.filters,
    required this.query,
  });

  final SearchResult result;
  final SearchFilters filters;
  final String query;

  @override
  List<Object?> get props => [result, filters, query];
}

/// Emitted when a shop's details have loaded successfully.
class ShopDetailLoaded extends DiscoveryState {
  const ShopDetailLoaded({required this.shop, required this.services});

  final Shop shop;
  final List<Service> services;

  @override
  List<Object?> get props => [shop, services];
}

/// Emitted when the user's favourites list has loaded.
class FavoritesLoaded extends DiscoveryState {
  const FavoritesLoaded(this.shops);

  final List<Shop> shops;

  @override
  List<Object?> get props => [shops];
}

/// Emitted when an operation ends in an error.
class DiscoveryError extends DiscoveryState {
  const DiscoveryError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
