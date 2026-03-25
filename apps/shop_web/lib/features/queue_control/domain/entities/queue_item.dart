import 'package:equatable/equatable.dart';

/// Represents a single item in the service queue.
class QueueItem extends Equatable {
  const QueueItem({
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

  /// One of: waiting, serving, completed, cancelled, noShow
  final String status;
  final DateTime joinedAt;
  final DateTime? estimatedServeTime;
  final int estimatedWaitMinutes;
  final String? assignedStaffId;
  final String? assignedStaffName;
  final String? notes;

  bool get isWaiting => status == 'waiting';
  bool get isServing => status == 'serving';
  bool get isCompleted => status == 'completed';
  bool get isCancelled => status == 'cancelled';
  bool get isNoShow => status == 'noShow';

  QueueItem copyWith({
    String? id,
    String? customerName,
    String? customerPhone,
    String? serviceName,
    int? position,
    String? status,
    DateTime? joinedAt,
    DateTime? estimatedServeTime,
    int? estimatedWaitMinutes,
    String? assignedStaffId,
    String? assignedStaffName,
    String? notes,
  }) {
    return QueueItem(
      id: id ?? this.id,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      serviceName: serviceName ?? this.serviceName,
      position: position ?? this.position,
      status: status ?? this.status,
      joinedAt: joinedAt ?? this.joinedAt,
      estimatedServeTime: estimatedServeTime ?? this.estimatedServeTime,
      estimatedWaitMinutes: estimatedWaitMinutes ?? this.estimatedWaitMinutes,
      assignedStaffId: assignedStaffId ?? this.assignedStaffId,
      assignedStaffName: assignedStaffName ?? this.assignedStaffName,
      notes: notes ?? this.notes,
    );
  }

  @override
  List<Object?> get props => [
        id,
        customerName,
        customerPhone,
        serviceName,
        position,
        status,
        joinedAt,
        estimatedServeTime,
        estimatedWaitMinutes,
        assignedStaffId,
        assignedStaffName,
        notes,
      ];
}
