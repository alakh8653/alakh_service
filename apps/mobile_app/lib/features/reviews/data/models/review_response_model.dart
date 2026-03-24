import '../../domain/entities/review.dart';

class ReviewResponseModel extends ReviewResponse {
  const ReviewResponseModel({
    required super.id,
    required super.ownerId,
    required super.ownerName,
    required super.content,
    required super.respondedAt,
  });

  factory ReviewResponseModel.fromJson(Map<String, dynamic> json) {
    return ReviewResponseModel(
      id: json['id'] as String,
      ownerId: json['owner_id'] as String,
      ownerName: json['owner_name'] as String,
      content: json['content'] as String,
      respondedAt: DateTime.parse(json['responded_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'owner_id': ownerId,
        'owner_name': ownerName,
        'content': content,
        'responded_at': respondedAt.toIso8601String(),
      };
}
