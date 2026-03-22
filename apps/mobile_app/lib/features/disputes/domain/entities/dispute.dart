import 'package:equatable/equatable.dart';
import 'dispute_type.dart';
import 'dispute_status.dart';
import 'dispute_evidence.dart';

class DisputeResolution extends Equatable {
  final String outcome;
  final double? refundAmount;
  final String notes;
  final String resolvedBy;

  const DisputeResolution({
    required this.outcome,
    this.refundAmount,
    required this.notes,
    required this.resolvedBy,
  });

  @override
  List<Object?> get props => [outcome, refundAmount, notes, resolvedBy];
}

class DisputeMessage extends Equatable {
  final String id;
  final String senderId;
  final String senderName;
  final String content;
  final DateTime sentAt;
  final bool isAdmin;

  const DisputeMessage({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.content,
    required this.sentAt,
    required this.isAdmin,
  });

  @override
  List<Object?> get props => [id, senderId, senderName, content, sentAt, isAdmin];
}

class Dispute extends Equatable {
  final String id;
  final String bookingId;
  final String userId;
  final String shopId;
  final DisputeType type;
  final String reason;
  final String description;
  final DisputeStatus status;
  final List<DisputeEvidence> evidence;
  final List<DisputeMessage> messages;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DisputeResolution? resolution;

  const Dispute({
    required this.id,
    required this.bookingId,
    required this.userId,
    required this.shopId,
    required this.type,
    required this.reason,
    required this.description,
    required this.status,
    required this.evidence,
    required this.messages,
    required this.createdAt,
    required this.updatedAt,
    this.resolution,
  });

  @override
  List<Object?> get props => [
        id, bookingId, userId, shopId, type, reason, description,
        status, evidence, messages, createdAt, updatedAt, resolution,
      ];
}
