import 'package:shop_web/features/queue_control/domain/entities/queue_item.dart';

/// Data-transfer object for a queue entry returned by the API.
class QueueItemModel {
  QueueItemModel({
    required this.id,
    required this.customerName,
    required this.customerPhone,
    required this.serviceName,
    required this.position,
    required this.status,
    required this.joinedAt,
    required this.estimatedWaitMinutes,
    this.estimatedServeTime,
    this.assignedStaffId,
    this.assignedStaffName,
    this.notes,
  });

  final String id;
  final String customerName;
  final String customerPhone;
  final String serviceName;
  final int position;
  final String status;
  final DateTime joinedAt;
  final DateTime? estimatedServeTime;
  final int estimatedWaitMinutes;
  final String? assignedStaffId;
  final String? assignedStaffName;
  final String? notes;

  /// Deserialises a JSON map from the API response.
  factory QueueItemModel.fromJson(Map<String, dynamic> json) {
    return QueueItemModel(
      id: json['id'] as String,
      customerName: json['customer_name'] as String,
      customerPhone: json['customer_phone'] as String,
      serviceName: json['service_name'] as String,
      position: json['position'] as int,
      status: json['status'] as String,
      joinedAt: DateTime.parse(json['joined_at'] as String),
      estimatedWaitMinutes: json['estimated_wait_minutes'] as int,
      estimatedServeTime: json['estimated_serve_time'] != null
          ? DateTime.parse(json['estimated_serve_time'] as String)
          : null,
      assignedStaffId: json['assigned_staff_id'] as String?,
      assignedStaffName: json['assigned_staff_name'] as String?,
      notes: json['notes'] as String?,
    );
  }

  /// Serialises this model to a JSON map for API requests.
  Map<String, dynamic> toJson() => {
        'id': id,
        'customer_name': customerName,
        'customer_phone': customerPhone,
        'service_name': serviceName,
        'position': position,
        'status': status,
        'joined_at': joinedAt.toIso8601String(),
        'estimated_wait_minutes': estimatedWaitMinutes,
        if (estimatedServeTime != null)
          'estimated_serve_time': estimatedServeTime!.toIso8601String(),
        if (assignedStaffId != null) 'assigned_staff_id': assignedStaffId,
        if (assignedStaffName != null)
          'assigned_staff_name': assignedStaffName,
        if (notes != null) 'notes': notes,
      };

  /// Converts this model to a domain [QueueItem] entity.
  QueueItem toEntity() => QueueItem(
        id: id,
        customerName: customerName,
        customerPhone: customerPhone,
        serviceName: serviceName,
        position: position,
        status: status,
        joinedAt: joinedAt,
        estimatedWaitMinutes: estimatedWaitMinutes,
        estimatedServeTime: estimatedServeTime,
        assignedStaffId: assignedStaffId,
        assignedStaffName: assignedStaffName,
        notes: notes,
      );
}
