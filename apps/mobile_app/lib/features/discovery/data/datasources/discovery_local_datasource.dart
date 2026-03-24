import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/models.dart';

/// Contract for the local (cache) data source.
abstract class DiscoveryLocalDataSource {
  Future<void> cacheCategories(List<CategoryModel> categories);
  Future<List<CategoryModel>> getCachedCategories();

  Future<void> cacheNearbyShops(List<ShopModel> shops);
  Future<List<ShopModel>> getCachedNearbyShops();

  Future<void> saveFavorite(ShopModel shop);
  Future<void> removeFavorite(String shopId);
  Future<List<ShopModel>> getFavorites();

  Future<void> saveRecentSearch(String query);
  Future<List<String>> getRecentSearches();
  Future<void> clearRecentSearches();
}

/// SharedPreferences-backed implementation of [DiscoveryLocalDataSource].
class DiscoveryLocalDataSourceImpl implements DiscoveryLocalDataSource {
  DiscoveryLocalDataSourceImpl({required this.prefs});

  final SharedPreferences prefs;

  static const _keyCachedCategories = 'cached_categories';
  static const _keyCachedNearbyShops = 'cached_nearby_shops';
  static const _keyFavorites = 'favorites';
  static const _keyRecentSearches = 'recent_searches';
  static const int _maxRecentSearches = 20;

  // ── categories ──────────────────────────────────────────────────────────

  @override
  Future<void> cacheCategories(List<CategoryModel> categories) async {
    final encoded =
        jsonEncode(categories.map((c) => c.toJson()).toList());
    await prefs.setString(_keyCachedCategories, encoded);
  }

  @override
  Future<List<CategoryModel>> getCachedCategories() async {
    final raw = prefs.getString(_keyCachedCategories);
    if (raw == null) return [];
    final decoded = jsonDecode(raw) as List;
    return decoded
        .map((e) => CategoryModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // ── nearby shops ─────────────────────────────────────────────────────────

  @override
  Future<void> cacheNearbyShops(List<ShopModel> shops) async {
    final encoded = jsonEncode(shops.map((s) => s.toJson()).toList());
    await prefs.setString(_keyCachedNearbyShops, encoded);
  }

  @override
  Future<List<ShopModel>> getCachedNearbyShops() async {
    final raw = prefs.getString(_keyCachedNearbyShops);
    if (raw == null) return [];
    final decoded = jsonDecode(raw) as List;
    return decoded
        .map((e) => ShopModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // ── favourites ───────────────────────────────────────────────────────────

  @override
  Future<void> saveFavorite(ShopModel shop) async {
    final existing = await getFavorites();
    if (existing.any((s) => s.id == shop.id)) return;
    final updated = [...existing, shop];
    await prefs.setString(
        _keyFavorites, jsonEncode(updated.map((s) => s.toJson()).toList()));
  }

  @override
  Future<void> removeFavorite(String shopId) async {
    final existing = await getFavorites();
    final updated = existing.where((s) => s.id != shopId).toList();
    await prefs.setString(
        _keyFavorites, jsonEncode(updated.map((s) => s.toJson()).toList()));
  }

  @override
  Future<List<ShopModel>> getFavorites() async {
    final raw = prefs.getString(_keyFavorites);
    if (raw == null) return [];
    final decoded = jsonDecode(raw) as List;
    return decoded
        .map((e) => ShopModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // ── recent searches ──────────────────────────────────────────────────────

  @override
  Future<void> saveRecentSearch(String query) async {
    final existing = await getRecentSearches();
    final updated = [query, ...existing.where((q) => q != query)]
        .take(_maxRecentSearches)
        .toList();
    await prefs.setStringList(_keyRecentSearches, updated);
  }

  @override
  Future<List<String>> getRecentSearches() async {
    return prefs.getStringList(_keyRecentSearches) ?? [];
  }

  @override
  Future<void> clearRecentSearches() async {
    await prefs.remove(_keyRecentSearches);
  }
}
