import 'package:equatable/equatable.dart';
import 'verification_type.dart';
import 'verification_status.dart';

class Verification extends Equatable {
  final String id;
  final VerificationType type;
  final VerificationStatus status;
  final DateTime? verifiedAt;
  final DateTime? expiresAt;
  final List<String> documents;

  const Verification({
    required this.id,
    required this.type,
    required this.status,
    this.verifiedAt,
    this.expiresAt,
    this.documents = const [],
  });

  bool get isExpired =>
      expiresAt != null && expiresAt!.isBefore(DateTime.now());

  @override
  List<Object?> get props =>
      [id, type, status, verifiedAt, expiresAt, documents];
}
