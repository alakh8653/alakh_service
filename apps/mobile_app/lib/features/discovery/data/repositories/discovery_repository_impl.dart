import 'package:dartz/dartz.dart';

import '../../core/failures.dart';
import '../../domain/entities/entities.dart';
import '../../domain/repositories/discovery_repository.dart';
import '../datasources/discovery_local_datasource.dart';
import '../datasources/discovery_remote_datasource.dart';
import '../models/filter_model.dart';

/// Concrete implementation of [DiscoveryRepository].
///
/// Tries the remote source first; falls back to cache when the remote fails.
class DiscoveryRepositoryImpl implements DiscoveryRepository {
  DiscoveryRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  final DiscoveryRemoteDataSource remoteDataSource;
  final DiscoveryLocalDataSource localDataSource;

  @override
  Future<Either<Failure, SearchResult>> searchServices(
      SearchParams params) async {
    try {
      final shops = await remoteDataSource.searchShops(
        query: params.query,
        filters: FilterModel(
          minPrice: params.filters.minPrice,
          maxPrice: params.filters.maxPrice,
          minRating: params.filters.minRating,
          maxDistanceKm: params.filters.maxDistanceKm,
          categoryId: params.filters.categoryId,
          sortBy: params.filters.sortBy,
          openNow: params.filters.openNow,
        ),
      );
      await localDataSource.saveRecentSearch(params.query);
      return Right(SearchResult(
        shops: shops,
        services: const [],
        totalCount: shops.length,
      ));
    } on ServerFailure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Shop>>> getNearbyShops(
      LocationParams params) async {
    try {
      final shops = await remoteDataSource.getNearbyShops(
        latitude: params.latitude,
        longitude: params.longitude,
        radiusKm: params.radiusKm,
      );
      await localDataSource.cacheNearbyShops(shops);
      return Right(shops);
    } on ServerFailure catch (_) {
      // Fallback to cache
      try {
        final cached = await localDataSource.getCachedNearbyShops();
        return Right(cached);
      } catch (e) {
        return Left(CacheFailure(e.toString()));
      }
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Category>>> getCategories() async {
    try {
      final categories = await remoteDataSource.getCategories();
      await localDataSource.cacheCategories(categories);
      return Right(categories);
    } on ServerFailure catch (_) {
      try {
        final cached = await localDataSource.getCachedCategories();
        return Right(cached);
      } catch (e) {
        return Left(CacheFailure(e.toString()));
      }
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Shop>> getShopDetails(String shopId) async {
    try {
      final shop = await remoteDataSource.getShopDetails(shopId);
      return Right(shop);
    } on ServerFailure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Service>>> getTrendingServices() async {
    try {
      final services = await remoteDataSource.getTrendingServices();
      return Right(services);
    } on ServerFailure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> addToFavorites(String shopId) async {
    try {
      await remoteDataSource.addToFavorites(shopId);
      return const Right(null);
    } on ServerFailure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> removeFromFavorites(String shopId) async {
    try {
      await remoteDataSource.removeFromFavorites(shopId);
      await localDataSource.removeFavorite(shopId);
      return const Right(null);
    } on ServerFailure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Shop>>> getFavorites() async {
    try {
      final shops = await remoteDataSource.getFavorites();
      return Right(shops);
    } on ServerFailure catch (_) {
      try {
        final cached = await localDataSource.getFavorites();
        return Right(cached);
      } catch (e) {
        return Left(CacheFailure(e.toString()));
      }
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<String>>> getRecentSearches() async {
    try {
      final searches = await localDataSource.getRecentSearches();
      return Right(searches);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> saveSearch(String query) async {
    try {
      await localDataSource.saveRecentSearch(query);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }
}
