import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/review_model.dart';

abstract class ReviewLocalDataSource {
  Future<void> cacheShopReviews(String shopId, List<ReviewModel> reviews);
  Future<List<ReviewModel>> getCachedShopReviews(String shopId);
  Future<void> cacheMyReviews(List<ReviewModel> reviews);
  Future<List<ReviewModel>> getCachedMyReviews();
  Future<void> clearCache();
}

class ReviewLocalDataSourceImpl implements ReviewLocalDataSource {
  final SharedPreferences sharedPreferences;
  static const String _shopReviewsPrefix = 'cached_shop_reviews_';
  static const String _myReviewsKey = 'cached_my_reviews';

  const ReviewLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<void> cacheShopReviews(String shopId, List<ReviewModel> reviews) async {
    await sharedPreferences.setString(
      '$_shopReviewsPrefix$shopId',
      jsonEncode(reviews.map((r) => r.toJson()).toList()),
    );
  }

  @override
  Future<List<ReviewModel>> getCachedShopReviews(String shopId) async {
    final jsonString =
        sharedPreferences.getString('$_shopReviewsPrefix$shopId');
    if (jsonString == null) return [];
    final list = jsonDecode(jsonString) as List<dynamic>;
    return list
        .map((e) => ReviewModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> cacheMyReviews(List<ReviewModel> reviews) async {
    await sharedPreferences.setString(
      _myReviewsKey,
      jsonEncode(reviews.map((r) => r.toJson()).toList()),
    );
  }

  @override
  Future<List<ReviewModel>> getCachedMyReviews() async {
    final jsonString = sharedPreferences.getString(_myReviewsKey);
    if (jsonString == null) return [];
    final list = jsonDecode(jsonString) as List<dynamic>;
    return list
        .map((e) => ReviewModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> clearCache() async {
    final keys = sharedPreferences
        .getKeys()
        .where((k) =>
            k.startsWith(_shopReviewsPrefix) || k == _myReviewsKey)
        .toList();
    for (final key in keys) {
      await sharedPreferences.remove(key);
    }
  }
}
