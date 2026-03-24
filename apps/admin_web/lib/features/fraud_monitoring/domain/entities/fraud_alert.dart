import 'package:equatable/equatable.dart';

/// Fraud alert entity representing a detected suspicious activity.
class FraudAlert extends Equatable {
  final String id;
  final String type;
  final String severity;
  final String userId;
  final Map<String, dynamic> details;
  final DateTime detectedAt;
  final String status;
  final String? notes;

  const FraudAlert({
    required this.id,
    required this.type,
    required this.severity,
    required this.userId,
    required this.details,
    required this.detectedAt,
    required this.status,
    this.notes,
  });

  @override
  List<Object?> get props => [id, type, severity, userId, detectedAt, status, notes];
}
