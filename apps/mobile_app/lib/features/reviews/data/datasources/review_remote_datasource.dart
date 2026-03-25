import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/review_model.dart';
import '../models/review_stats_model.dart';

abstract class ReviewRemoteDataSource {
  Future<ReviewModel> submitReview({
    required String bookingId,
    required String shopId,
    required double rating,
    required String title,
    required String text,
    required List<String> photos,
  });

  Future<List<ReviewModel>> getShopReviews({
    required String shopId,
    int? page,
    int? perPage,
    int? filterRating,
  });

  Future<List<ReviewModel>> getMyReviews();
  Future<ReviewModel> getReviewDetails(String reviewId);

  Future<ReviewModel> editReview({
    required String reviewId,
    required double rating,
    required String title,
    required String text,
    required List<String> photos,
  });

  Future<bool> deleteReview(String reviewId);

  Future<bool> reportReview({
    required String reviewId,
    required String reason,
  });

  Future<bool> markReviewHelpful(String reviewId);
  Future<ReviewStatsModel> getReviewStats(String shopId);

  Future<ReviewModel> respondToReview({
    required String reviewId,
    required String content,
  });
}

class ReviewRemoteDataSourceImpl implements ReviewRemoteDataSource {
  final http.Client client;
  final String baseUrl;
  final String authToken;

  const ReviewRemoteDataSourceImpl({
    required this.client,
    required this.baseUrl,
    required this.authToken,
  });

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $authToken',
      };

  @override
  Future<ReviewModel> submitReview({
    required String bookingId,
    required String shopId,
    required double rating,
    required String title,
    required String text,
    required List<String> photos,
  }) async {
    final response = await client.post(
      Uri.parse('$baseUrl/api/v1/reviews'),
      headers: _headers,
      body: jsonEncode({
        'booking_id': bookingId,
        'shop_id': shopId,
        'rating': rating,
        'title': title,
        'text': text,
        'photos': photos,
      }),
    );
    if (response.statusCode == 201) {
      return ReviewModel.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>);
    }
    throw Exception('Failed to submit review: ${response.statusCode}');
  }

  @override
  Future<List<ReviewModel>> getShopReviews({
    required String shopId,
    int? page,
    int? perPage,
    int? filterRating,
  }) async {
    final params = <String, String>{};
    if (page != null) params['page'] = page.toString();
    if (perPage != null) params['per_page'] = perPage.toString();
    if (filterRating != null) params['rating'] = filterRating.toString();

    final uri = Uri.parse('$baseUrl/api/v1/reviews/shops/$shopId')
        .replace(queryParameters: params.isNotEmpty ? params : null);

    final response = await client.get(uri, headers: _headers);
    if (response.statusCode == 200) {
      final list = jsonDecode(response.body) as List<dynamic>;
      return list
          .map((e) => ReviewModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    throw Exception('Failed to get reviews: ${response.statusCode}');
  }

  @override
  Future<List<ReviewModel>> getMyReviews() async {
    final response = await client.get(
      Uri.parse('$baseUrl/api/v1/reviews/mine'),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      final list = jsonDecode(response.body) as List<dynamic>;
      return list
          .map((e) => ReviewModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    throw Exception('Failed to get my reviews: ${response.statusCode}');
  }

  @override
  Future<ReviewModel> getReviewDetails(String reviewId) async {
    final response = await client.get(
      Uri.parse('$baseUrl/api/v1/reviews/$reviewId'),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      return ReviewModel.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>);
    }
    throw Exception('Failed to get review: ${response.statusCode}');
  }

  @override
  Future<ReviewModel> editReview({
    required String reviewId,
    required double rating,
    required String title,
    required String text,
    required List<String> photos,
  }) async {
    final response = await client.put(
      Uri.parse('$baseUrl/api/v1/reviews/$reviewId'),
      headers: _headers,
      body: jsonEncode({
        'rating': rating,
        'title': title,
        'text': text,
        'photos': photos,
      }),
    );
    if (response.statusCode == 200) {
      return ReviewModel.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>);
    }
    throw Exception('Failed to edit review: ${response.statusCode}');
  }

  @override
  Future<bool> deleteReview(String reviewId) async {
    final response = await client.delete(
      Uri.parse('$baseUrl/api/v1/reviews/$reviewId'),
      headers: _headers,
    );
    return response.statusCode == 200 || response.statusCode == 204;
  }

  @override
  Future<bool> reportReview({
    required String reviewId,
    required String reason,
  }) async {
    final response = await client.post(
      Uri.parse('$baseUrl/api/v1/reviews/$reviewId/report'),
      headers: _headers,
      body: jsonEncode({'reason': reason}),
    );
    return response.statusCode == 200 || response.statusCode == 201;
  }

  @override
  Future<bool> markReviewHelpful(String reviewId) async {
    final response = await client.post(
      Uri.parse('$baseUrl/api/v1/reviews/$reviewId/helpful'),
      headers: _headers,
    );
    return response.statusCode == 200 || response.statusCode == 201;
  }

  @override
  Future<ReviewStatsModel> getReviewStats(String shopId) async {
    final response = await client.get(
      Uri.parse('$baseUrl/api/v1/reviews/shops/$shopId/stats'),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      return ReviewStatsModel.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>);
    }
    throw Exception('Failed to get review stats: ${response.statusCode}');
  }

  @override
  Future<ReviewModel> respondToReview({
    required String reviewId,
    required String content,
  }) async {
    final response = await client.post(
      Uri.parse('$baseUrl/api/v1/reviews/$reviewId/response'),
      headers: _headers,
      body: jsonEncode({'content': content}),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      return ReviewModel.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>);
    }
    throw Exception('Failed to respond to review: ${response.statusCode}');
  }
}
