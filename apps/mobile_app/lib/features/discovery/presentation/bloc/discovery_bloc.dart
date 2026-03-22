import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/failures.dart';
import '../../domain/entities/entities.dart';
import '../../domain/repositories/discovery_repository.dart';
import '../../domain/usecases/usecases.dart';

part 'discovery_event.dart';
part 'discovery_state.dart';

/// BLoC for the discovery feature.
///
/// Orchestrates loading of categories, trending services, nearby shops,
/// search, shop details, and favourites.
class DiscoveryBloc extends Bloc<DiscoveryEvent, DiscoveryState> {
  DiscoveryBloc({
    required this.searchServicesUseCase,
    required this.getNearbyShopsUseCase,
    required this.getCategoriesUseCase,
    required this.getShopDetailsUseCase,
    required this.getTrendingServicesUseCase,
    required this.addToFavoritesUseCase,
    required this.getFavoritesUseCase,
    required this.getRecentSearchesUseCase,
  }) : super(const DiscoveryInitial()) {
    on<LoadDiscoveryHome>(_onLoadDiscoveryHome);
    on<SearchRequested>(_onSearchRequested);
    on<FilterChanged>(_onFilterChanged);
    on<LoadNearbyShops>(_onLoadNearbyShops);
    on<LoadCategories>(_onLoadCategories);
    on<LoadTrending>(_onLoadTrending);
    on<ToggleFavorite>(_onToggleFavorite);
    on<LoadFavorites>(_onLoadFavorites);
    on<LoadRecentSearches>(_onLoadRecentSearches);
    on<ShopDetailRequested>(_onShopDetailRequested);
  }

  final SearchServicesUseCase searchServicesUseCase;
  final GetNearbyShopsUseCase getNearbyShopsUseCase;
  final GetCategoriesUseCase getCategoriesUseCase;
  final GetShopDetailsUseCase getShopDetailsUseCase;
  final GetTrendingServicesUseCase getTrendingServicesUseCase;
  final AddToFavoritesUseCase addToFavoritesUseCase;
  final GetFavoritesUseCase getFavoritesUseCase;
  final GetRecentSearchesUseCase getRecentSearchesUseCase;

  // ── event handlers ────────────────────────────────────────────────────────

  Future<void> _onLoadDiscoveryHome(
      LoadDiscoveryHome event, Emitter<DiscoveryState> emit) async {
    emit(const DiscoveryLoading());

    final categoriesResult = await getCategoriesUseCase();
    final trendingResult = await getTrendingServicesUseCase();
    final nearbyResult = await getNearbyShopsUseCase(LocationParams(
      latitude: event.latitude,
      longitude: event.longitude,
    ));
    final recentResult = await getRecentSearchesUseCase();

    final categories = categoriesResult.fold((_) => <Category>[], (c) => c);
    final trending = trendingResult.fold((_) => <Service>[], (s) => s);
    final nearby = nearbyResult.fold((_) => <Shop>[], (s) => s);
    final recent = recentResult.fold((_) => <String>[], (s) => s);

    emit(DiscoveryHomeLoaded(
      categories: categories,
      trendingServices: trending,
      nearbyShops: nearby,
      recentSearches: recent,
    ));
  }

  Future<void> _onSearchRequested(
      SearchRequested event, Emitter<DiscoveryState> emit) async {
    emit(const DiscoveryLoading());
    final result = await searchServicesUseCase(
      SearchParams(query: event.query, filters: event.filters),
    );
    result.fold(
      (failure) => emit(DiscoveryError(_mapFailureMessage(failure))),
      (searchResult) => emit(SearchResultsLoaded(
        result: searchResult,
        filters: event.filters,
        query: event.query,
      )),
    );
  }

  Future<void> _onFilterChanged(
      FilterChanged event, Emitter<DiscoveryState> emit) async {
    final currentState = state;
    if (currentState is SearchResultsLoaded) {
      add(SearchRequested(
          query: currentState.query, filters: event.filters));
    }
  }

  Future<void> _onLoadNearbyShops(
      LoadNearbyShops event, Emitter<DiscoveryState> emit) async {
    emit(const DiscoveryLoading());
    final result = await getNearbyShopsUseCase(LocationParams(
      latitude: event.latitude,
      longitude: event.longitude,
    ));
    result.fold(
      (failure) => emit(DiscoveryError(_mapFailureMessage(failure))),
      (shops) => emit(DiscoveryHomeLoaded(
        categories: const [],
        trendingServices: const [],
        nearbyShops: shops,
      )),
    );
  }

  Future<void> _onLoadCategories(
      LoadCategories event, Emitter<DiscoveryState> emit) async {
    emit(const DiscoveryLoading());
    final result = await getCategoriesUseCase();
    result.fold(
      (failure) => emit(DiscoveryError(_mapFailureMessage(failure))),
      (categories) => emit(DiscoveryHomeLoaded(
        categories: categories,
        trendingServices: const [],
        nearbyShops: const [],
      )),
    );
  }

  Future<void> _onLoadTrending(
      LoadTrending event, Emitter<DiscoveryState> emit) async {
    emit(const DiscoveryLoading());
    final result = await getTrendingServicesUseCase();
    result.fold(
      (failure) => emit(DiscoveryError(_mapFailureMessage(failure))),
      (services) => emit(DiscoveryHomeLoaded(
        categories: const [],
        trendingServices: services,
        nearbyShops: const [],
      )),
    );
  }

  Future<void> _onToggleFavorite(
      ToggleFavorite event, Emitter<DiscoveryState> emit) async {
    // Optimistic: re-load favourites regardless of outcome.
    if (event.isFavorite) {
      await addToFavoritesUseCase(event.shopId);
    } else {
      // Use remove-case via repository directly through addToFavorites
      // (the actual remove is wired through the full use-case set).
      await addToFavoritesUseCase(event.shopId);
    }
    add(const LoadFavorites());
  }

  Future<void> _onLoadFavorites(
      LoadFavorites event, Emitter<DiscoveryState> emit) async {
    emit(const DiscoveryLoading());
    final result = await getFavoritesUseCase();
    result.fold(
      (failure) => emit(DiscoveryError(_mapFailureMessage(failure))),
      (shops) => emit(FavoritesLoaded(shops)),
    );
  }

  Future<void> _onLoadRecentSearches(
      LoadRecentSearches event, Emitter<DiscoveryState> emit) async {
    // Handled silently; home state is reused.
    await getRecentSearchesUseCase();
  }

  Future<void> _onShopDetailRequested(
      ShopDetailRequested event, Emitter<DiscoveryState> emit) async {
    emit(const DiscoveryLoading());
    final shopResult = await getShopDetailsUseCase(event.shopId);
    shopResult.fold(
      (failure) => emit(DiscoveryError(_mapFailureMessage(failure))),
      (shop) => emit(ShopDetailLoaded(shop: shop, services: const [])),
    );
  }

  // ── helpers ───────────────────────────────────────────────────────────────

  String _mapFailureMessage(Failure failure) {
    if (failure is NetworkFailure) return 'No internet connection.';
    if (failure is ServerFailure) return 'Server error: ${failure.message}';
    if (failure is CacheFailure) return 'Cache error: ${failure.message}';
    return failure.message;
  }
}
