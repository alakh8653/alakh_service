import 'package:equatable/equatable.dart';

/// Blacklist entry entity.
class BlacklistEntry extends Equatable {
  final String id;
  final String entityId;
  final String entityType;
  final String reason;
  final DateTime addedAt;
  final String addedBy;
  final DateTime? expiresAt;

  const BlacklistEntry({
    required this.id,
    required this.entityId,
    required this.entityType,
    required this.reason,
    required this.addedAt,
    required this.addedBy,
    this.expiresAt,
  });

  @override
  List<Object?> get props => [id, entityId, entityType, reason, addedAt, addedBy, expiresAt];
}
