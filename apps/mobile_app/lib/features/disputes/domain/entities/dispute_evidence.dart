import 'package:equatable/equatable.dart';

enum EvidenceType { photo, video, text }

class DisputeEvidence extends Equatable {
  final String id;
  final EvidenceType type;
  final String url;
  final String description;
  final DateTime uploadedAt;

  const DisputeEvidence({
    required this.id,
    required this.type,
    required this.url,
    required this.description,
    required this.uploadedAt,
  });

  @override
  List<Object?> get props => [id, type, url, description, uploadedAt];
}
