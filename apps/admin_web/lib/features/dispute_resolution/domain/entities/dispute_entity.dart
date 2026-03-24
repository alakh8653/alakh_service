import 'package:equatable/equatable.dart';

enum DisputeType {
  paymentIssue,
  serviceQuality,
  cancelRefund,
  fraud,
  other;

  static DisputeType fromString(String value) {
    switch (value.toLowerCase()) {
      case 'payment_issue':
      case 'paymentissue':
        return DisputeType.paymentIssue;
      case 'service_quality':
      case 'servicequality':
        return DisputeType.serviceQuality;
      case 'cancel_refund':
      case 'cancelrefund':
        return DisputeType.cancelRefund;
      case 'fraud':
        return DisputeType.fraud;
      case 'other':
      default:
        return DisputeType.other;
    }
  }

  String get displayName {
    switch (this) {
      case DisputeType.paymentIssue:
        return 'Payment Issue';
      case DisputeType.serviceQuality:
        return 'Service Quality';
      case DisputeType.cancelRefund:
        return 'Cancel/Refund';
      case DisputeType.fraud:
        return 'Fraud';
      case DisputeType.other:
        return 'Other';
    }
  }
}

enum DisputeStatus {
  open,
  inProgress,
  pendingCustomer,
  pendingShop,
  resolved,
  closed,
  escalated;

  static DisputeStatus fromString(String value) {
    switch (value.toLowerCase()) {
      case 'in_progress':
      case 'inprogress':
        return DisputeStatus.inProgress;
      case 'pending_customer':
      case 'pendingcustomer':
        return DisputeStatus.pendingCustomer;
      case 'pending_shop':
      case 'pendingshop':
        return DisputeStatus.pendingShop;
      case 'resolved':
        return DisputeStatus.resolved;
      case 'closed':
        return DisputeStatus.closed;
      case 'escalated':
        return DisputeStatus.escalated;
      case 'open':
      default:
        return DisputeStatus.open;
    }
  }

  String get displayName {
    switch (this) {
      case DisputeStatus.open:
        return 'Open';
      case DisputeStatus.inProgress:
        return 'In Progress';
      case DisputeStatus.pendingCustomer:
        return 'Pending Customer';
      case DisputeStatus.pendingShop:
        return 'Pending Shop';
      case DisputeStatus.resolved:
        return 'Resolved';
      case DisputeStatus.closed:
        return 'Closed';
      case DisputeStatus.escalated:
        return 'Escalated';
    }
  }
}

enum DisputePriority {
  low,
  medium,
  high,
  critical;

  static DisputePriority fromString(String value) {
    switch (value.toLowerCase()) {
      case 'medium':
        return DisputePriority.medium;
      case 'high':
        return DisputePriority.high;
      case 'critical':
        return DisputePriority.critical;
      case 'low':
      default:
        return DisputePriority.low;
    }
  }

  String get displayName {
    switch (this) {
      case DisputePriority.low:
        return 'Low';
      case DisputePriority.medium:
        return 'Medium';
      case DisputePriority.high:
        return 'High';
      case DisputePriority.critical:
        return 'Critical';
    }
  }
}

class DisputeTimelineEvent extends Equatable {
  final String id;
  final String action;
  final String description;
  final String performedBy;
  final DateTime performedAt;
  final List<String> attachments;

  const DisputeTimelineEvent({
    required this.id,
    required this.action,
    required this.description,
    required this.performedBy,
    required this.performedAt,
    this.attachments = const [],
  });

  @override
  List<Object?> get props =>
      [id, action, description, performedBy, performedAt, attachments];
}

class DisputeEntity extends Equatable {
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
  final List<DisputeTimelineEvent> timeline;
  final List<String> attachments;

  const DisputeEntity({
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

  DisputeEntity copyWith({
    String? id,
    String? ticketNumber,
    String? title,
    String? description,
    DisputeType? type,
    DisputeStatus? status,
    DisputePriority? priority,
    String? customerId,
    String? customerName,
    String? customerPhone,
    String? shopId,
    String? shopName,
    String? orderId,
    double? amount,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? resolvedAt,
    String? resolvedBy,
    String? resolution,
    List<DisputeTimelineEvent>? timeline,
    List<String>? attachments,
  }) {
    return DisputeEntity(
      id: id ?? this.id,
      ticketNumber: ticketNumber ?? this.ticketNumber,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      shopId: shopId ?? this.shopId,
      shopName: shopName ?? this.shopName,
      orderId: orderId ?? this.orderId,
      amount: amount ?? this.amount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      resolvedAt: resolvedAt ?? this.resolvedAt,
      resolvedBy: resolvedBy ?? this.resolvedBy,
      resolution: resolution ?? this.resolution,
      timeline: timeline ?? this.timeline,
      attachments: attachments ?? this.attachments,
    );
  }

  @override
  List<Object?> get props => [
        id,
        ticketNumber,
        title,
        description,
        type,
        status,
        priority,
        customerId,
        customerName,
        customerPhone,
        shopId,
        shopName,
        orderId,
        amount,
        createdAt,
        updatedAt,
        resolvedAt,
        resolvedBy,
        resolution,
        timeline,
        attachments,
      ];
}
