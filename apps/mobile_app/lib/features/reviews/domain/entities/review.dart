import 'package:equatable/equatable.dart';

class ReviewResponse extends Equatable {
  final String id;
  final String ownerId;
  final String ownerName;
  final String content;
  final DateTime respondedAt;

  const ReviewResponse({
    required this.id,
    required this.ownerId,
    required this.ownerName,
    required this.content,
    required this.respondedAt,
  });

  @override
  List<Object?> get props => [id, ownerId, ownerName, content, respondedAt];
}

class Review extends Equatable {
  final String id;
  final String bookingId;
  final String userId;
  final String userName;
  final String? userAvatar;
  final String shopId;
  final double rating;
  final String title;
  final String text;
  final List<String> photos;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int helpfulCount;
  final ReviewResponse? ownerResponse;
  final bool isReported;

  const Review({
    required this.id,
    required this.bookingId,
    required this.userId,
    required this.userName,
    this.userAvatar,
    required this.shopId,
    required this.rating,
    required this.title,
    required this.text,
    required this.photos,
    required this.createdAt,
    required this.updatedAt,
    required this.helpfulCount,
    this.ownerResponse,
    this.isReported = false,
  });

  @override
  List<Object?> get props => [
        id, bookingId, userId, userName, userAvatar, shopId, rating, title,
        text, photos, createdAt, updatedAt, helpfulCount, ownerResponse, isReported,
      ];
}
