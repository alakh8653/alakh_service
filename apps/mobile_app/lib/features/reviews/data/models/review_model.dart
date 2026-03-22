import '../../domain/entities/review.dart';
import 'review_response_model.dart';

class ReviewModel extends Review {
  const ReviewModel({
    required super.id,
    required super.bookingId,
    required super.userId,
    required super.userName,
    super.userAvatar,
    required super.shopId,
    required super.rating,
    required super.title,
    required super.text,
    required super.photos,
    required super.createdAt,
    required super.updatedAt,
    required super.helpfulCount,
    super.ownerResponse,
    super.isReported,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: json['id'] as String,
      bookingId: json['booking_id'] as String,
      userId: json['user_id'] as String,
      userName: json['user_name'] as String,
      userAvatar: json['user_avatar'] as String?,
      shopId: json['shop_id'] as String,
      rating: (json['rating'] as num).toDouble(),
      title: json['title'] as String,
      text: json['text'] as String,
      photos: (json['photos'] as List<dynamic>? ?? [])
          .map((e) => e as String)
          .toList(),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      helpfulCount: json['helpful_count'] as int? ?? 0,
      ownerResponse: json['owner_response'] != null
          ? ReviewResponseModel.fromJson(
              json['owner_response'] as Map<String, dynamic>)
          : null,
      isReported: json['is_reported'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'booking_id': bookingId,
        'user_id': userId,
        'user_name': userName,
        'user_avatar': userAvatar,
        'shop_id': shopId,
        'rating': rating,
        'title': title,
        'text': text,
        'photos': photos,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
        'helpful_count': helpfulCount,
        'owner_response': ownerResponse != null
            ? (ownerResponse as ReviewResponseModel).toJson()
            : null,
        'is_reported': isReported,
      };
}
