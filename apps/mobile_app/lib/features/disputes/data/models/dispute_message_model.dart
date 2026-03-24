import '../../domain/entities/dispute.dart';

class DisputeMessageModel extends DisputeMessage {
  const DisputeMessageModel({
    required super.id,
    required super.senderId,
    required super.senderName,
    required super.content,
    required super.sentAt,
    required super.isAdmin,
  });

  factory DisputeMessageModel.fromJson(Map<String, dynamic> json) {
    return DisputeMessageModel(
      id: json['id'] as String,
      senderId: json['sender_id'] as String,
      senderName: json['sender_name'] as String,
      content: json['content'] as String,
      sentAt: DateTime.parse(json['sent_at'] as String),
      isAdmin: json['is_admin'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'sender_id': senderId,
        'sender_name': senderName,
        'content': content,
        'sent_at': sentAt.toIso8601String(),
        'is_admin': isAdmin,
      };
}
