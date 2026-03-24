import '../../domain/entities/safety_report.dart';

class SafetyReportModel extends SafetyReport {
  const SafetyReportModel({
    required super.id,
    required super.type,
    required super.description,
    required super.reportedBy,
    required super.status,
    required super.createdAt,
  });

  factory SafetyReportModel.fromJson(Map<String, dynamic> json) {
    return SafetyReportModel(
      id: json['id'] as String,
      type: json['type'] as String,
      description: json['description'] as String,
      reportedBy: json['reported_by'] as String,
      status: json['status'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type,
        'description': description,
        'reported_by': reportedBy,
        'status': status,
        'created_at': createdAt.toIso8601String(),
      };
}
