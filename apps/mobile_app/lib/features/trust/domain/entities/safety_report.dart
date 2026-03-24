import 'package:equatable/equatable.dart';

class SafetyReport extends Equatable {
  final String id;
  final String type;
  final String description;
  final String reportedBy;
  final String status;
  final DateTime createdAt;

  const SafetyReport({
    required this.id,
    required this.type,
    required this.description,
    required this.reportedBy,
    required this.status,
    required this.createdAt,
  });

  @override
  List<Object?> get props =>
      [id, type, description, reportedBy, status, createdAt];
}
