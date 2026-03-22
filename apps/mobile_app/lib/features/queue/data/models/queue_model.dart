import '../../domain/entities/queue.dart';

/// Data model that extends [Queue] with JSON serialisation support.
///
/// This model lives in the data layer and is produced by datasources.
/// It is converted to/from the domain [Queue] entity by the repository.
class QueueModel extends Queue {
  /// Creates a [QueueModel].
  const QueueModel({
    required super.id,
    required super.shopId,
    required super.name,
    required super.currentSize,
    required super.averageWaitTime,
    required super.isActive,
    required super.maxCapacity,
  });

  /// Creates a [QueueModel] from a JSON map.
  ///
  /// Expects [averageWaitMinutes] as a number in minutes.
  factory QueueModel.fromJson(Map<String, dynamic> json) {
    return QueueModel(
      id: json['id'] as String,
      shopId: json['shop_id'] as String,
      name: json['name'] as String,
      currentSize: (json['current_size'] as num).toInt(),
      averageWaitTime: Duration(
        minutes: (json['average_wait_minutes'] as num).toInt(),
      ),
      isActive: json['is_active'] as bool,
      maxCapacity: (json['max_capacity'] as num).toInt(),
    );
  }

  /// Serialises this model to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'shop_id': shopId,
      'name': name,
      'current_size': currentSize,
      'average_wait_minutes': averageWaitTime.inMinutes,
      'is_active': isActive,
      'max_capacity': maxCapacity,
    };
  }

  /// Creates a copy of this model with the provided fields replaced.
  QueueModel copyWith({
    String? id,
    String? shopId,
    String? name,
    int? currentSize,
    Duration? averageWaitTime,
    bool? isActive,
    int? maxCapacity,
  }) {
    return QueueModel(
      id: id ?? this.id,
      shopId: shopId ?? this.shopId,
      name: name ?? this.name,
      currentSize: currentSize ?? this.currentSize,
      averageWaitTime: averageWaitTime ?? this.averageWaitTime,
      isActive: isActive ?? this.isActive,
      maxCapacity: maxCapacity ?? this.maxCapacity,
    );
  }

  /// Creates a [QueueModel] from its domain [Queue] counterpart.
  factory QueueModel.fromEntity(Queue queue) {
    return QueueModel(
      id: queue.id,
      shopId: queue.shopId,
      name: queue.name,
      currentSize: queue.currentSize,
      averageWaitTime: queue.averageWaitTime,
      isActive: queue.isActive,
      maxCapacity: queue.maxCapacity,
    );
  }
}
