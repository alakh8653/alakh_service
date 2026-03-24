import 'package:admin_web/features/dispute_resolution/domain/entities/dispute_entity.dart';

class DisputeTimelineEventModel {
  final String id;
  final String action;
  final String description;
  final String performedBy;
  final DateTime performedAt;
  final List<String> attachments;

  const DisputeTimelineEventModel({
    required this.id,
    required this.action,
    required this.description,
    required this.performedBy,
    required this.performedAt,
    this.attachments = const [],
  });

  factory DisputeTimelineEventModel.fromJson(Map<String, dynamic> json) {
    return DisputeTimelineEventModel(
      id: json['id'] as String,
      action: json['action'] as String,
      description: json['description'] as String,
      performedBy: json['performedBy'] as String? ??
          json['performed_by'] as String,
      performedAt: DateTime.parse(
          json['performedAt'] as String? ?? json['performed_at'] as String),
      attachments: (json['attachments'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'action': action,
        'description': description,
        'performedBy': performedBy,
        'performedAt': performedAt.toIso8601String(),
        'attachments': attachments,
      };

  DisputeTimelineEvent toEntity() => DisputeTimelineEvent(
        id: id,
        action: action,
        description: description,
        performedBy: performedBy,
        performedAt: performedAt,
        attachments: attachments,
      );
}

class DisputeModel {
  final String id;
  final String ticketNumber;
  final String title;
  final String description;
  final DisputeType type;
  final DisputeStatus status;
  final DisputePriority priority;
  final String customerId;
  final String customerName;
  final String customerPhone;
  final String shopId;
  final String shopName;
  final String? orderId;
  final double? amount;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? resolvedAt;
  final String? resolvedBy;
  final String? resolution;
  final List<DisputeTimelineEventModel> timeline;
  final List<String> attachments;

  const DisputeModel({
    required this.id,
    required this.ticketNumber,
    required this.title,
    required this.description,
    required this.type,
    required this.status,
    required this.priority,
    required this.customerId,
    required this.customerName,
    required this.customerPhone,
    required this.shopId,
    required this.shopName,
    this.orderId,
    this.amount,
    required this.createdAt,
    required this.updatedAt,
    this.resolvedAt,
    this.resolvedBy,
    this.resolution,
    this.timeline = const [],
    this.attachments = const [],
  });

  factory DisputeModel.fromJson(Map<String, dynamic> json) {
    return DisputeModel(
      id: json['id'] as String,
      ticketNumber: json['ticketNumber'] as String? ??
          json['ticket_number'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      type: DisputeType.fromString(json['type'] as String),
      status: DisputeStatus.fromString(json['status'] as String),
      priority: DisputePriority.fromString(json['priority'] as String),
      customerId: json['customerId'] as String? ??
          json['customer_id'] as String,
      customerName: json['customerName'] as String? ??
          json['customer_name'] as String,
      customerPhone: json['customerPhone'] as String? ??
          json['customer_phone'] as String,
      shopId: json['shopId'] as String? ?? json['shop_id'] as String,
      shopName: json['shopName'] as String? ?? json['shop_name'] as String,
      orderId: json['orderId'] as String? ?? json['order_id'] as String?,
      amount:
          json['amount'] != null ? (json['amount'] as num).toDouble() : null,
      createdAt: DateTime.parse(
          json['createdAt'] as String? ?? json['created_at'] as String),
      updatedAt: DateTime.parse(
          json['updatedAt'] as String? ?? json['updated_at'] as String),
      resolvedAt: json['resolvedAt'] != null || json['resolved_at'] != null
          ? DateTime.parse(
              json['resolvedAt'] as String? ?? json['resolved_at'] as String)
          : null,
      resolvedBy:
          json['resolvedBy'] as String? ?? json['resolved_by'] as String?,
      resolution: json['resolution'] as String?,
      timeline: (json['timeline'] as List<dynamic>?)
              ?.map((e) => DisputeTimelineEventModel.fromJson(
                  e as Map<String, dynamic>))
              .toList() ??
          [],
      attachments: (json['attachments'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'ticketNumber': ticketNumber,
        'title': title,
        'description': description,
        'type': type.name,
        'status': status.name,
        'priority': priority.name,
        'customerId': customerId,
        'customerName': customerName,
        'customerPhone': customerPhone,
        'shopId': shopId,
        'shopName': shopName,
        'orderId': orderId,
        'amount': amount,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'resolvedAt': resolvedAt?.toIso8601String(),
        'resolvedBy': resolvedBy,
        'resolution': resolution,
        'timeline': timeline.map((t) => t.toJson()).toList(),
        'attachments': attachments,
      };

  DisputeEntity toEntity() => DisputeEntity(
        id: id,
        ticketNumber: ticketNumber,
        title: title,
        description: description,
        type: type,
        status: status,
        priority: priority,
        customerId: customerId,
        customerName: customerName,
        customerPhone: customerPhone,
        shopId: shopId,
        shopName: shopName,
        orderId: orderId,
        amount: amount,
        createdAt: createdAt,
        updatedAt: updatedAt,
        resolvedAt: resolvedAt,
        resolvedBy: resolvedBy,
        resolution: resolution,
        timeline: timeline.map((t) => t.toEntity()).toList(),
        attachments: attachments,
      );
}
