import 'package:equatable/equatable.dart';

/// Represents a customer review for a shop after a completed booking.
class Review extends Equatable {
  /// Unique identifier.
  final String id;

  /// ID of the user who wrote the review.
  final String userId;

  /// ID of the shop being reviewed.
  final String shopId;

  /// ID of the completed booking this review is linked to.
  final String bookingId;

  /// Numeric rating, typically in the range 1.0–5.0.
  final double rating;

  /// Written review text.
  final String text;

  /// Optional list of photo URLs attached to the review.
  final List<String> photos;

  /// UTC timestamp when the review was created.
  final DateTime createdAt;

  const Review({
    required this.id,
    required this.userId,
    required this.shopId,
    required this.bookingId,
    required this.rating,
    required this.text,
    required this.photos,
    required this.createdAt,
  });

  /// Creates a [Review] from a JSON map.
  factory Review.fromJson(Map<String, dynamic> json) => Review(
        id: json['id'] as String,
        userId: json['userId'] as String,
        shopId: json['shopId'] as String,
        bookingId: json['bookingId'] as String,
        rating: (json['rating'] as num).toDouble(),
        text: json['text'] as String,
        photos:
            (json['photos'] as List<dynamic>).map((e) => e as String).toList(),
        createdAt: DateTime.parse(json['createdAt'] as String),
      );

  /// Converts this instance to a JSON map.
  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'shopId': shopId,
        'bookingId': bookingId,
        'rating': rating,
        'text': text,
        'photos': photos,
        'createdAt': createdAt.toIso8601String(),
      };

  /// Returns a copy with optionally overridden fields.
  Review copyWith({
    String? id,
    String? userId,
    String? shopId,
    String? bookingId,
    double? rating,
    String? text,
    List<String>? photos,
    DateTime? createdAt,
  }) =>
      Review(
        id: id ?? this.id,
        userId: userId ?? this.userId,
        shopId: shopId ?? this.shopId,
        bookingId: bookingId ?? this.bookingId,
        rating: rating ?? this.rating,
        text: text ?? this.text,
        photos: photos ?? this.photos,
        createdAt: createdAt ?? this.createdAt,
      );

  @override
  List<Object?> get props =>
      [id, userId, shopId, bookingId, rating, text, photos, createdAt];

  @override
  String toString() =>
      'Review(id: $id, userId: $userId, shopId: $shopId, '
      'bookingId: $bookingId, rating: $rating, createdAt: $createdAt)';
}
