import 'package:equatable/equatable.dart';

/// Domain entity representing a queue in a shop/service location.
///
/// This is a pure domain object with no framework or persistence dependencies.
class Queue extends Equatable {
  /// Unique identifier of the queue.
  final String id;

  /// Identifier of the shop this queue belongs to.
  final String shopId;

  /// Display name for the queue.
  final String name;

  /// Current number of entries in the queue.
  final int currentSize;

  /// Average estimated wait time calculated from historical data.
  final Duration averageWaitTime;

  /// Whether the queue is currently accepting new entries.
  final bool isActive;

  /// Maximum number of entries the queue can hold at one time.
  final int maxCapacity;

  /// Creates a [Queue] entity.
  const Queue({
    required this.id,
    required this.shopId,
    required this.name,
    required this.currentSize,
    required this.averageWaitTime,
    required this.isActive,
    required this.maxCapacity,
  });

  /// Returns `true` when the queue can still accept new entries.
  bool get hasCapacity => isActive && currentSize < maxCapacity;

  /// Percentage of capacity currently used (0.0 – 1.0).
  double get capacityRatio =>
      maxCapacity > 0 ? (currentSize / maxCapacity).clamp(0.0, 1.0) : 0.0;

  @override
  List<Object?> get props => [
        id,
        shopId,
        name,
        currentSize,
        averageWaitTime,
        isActive,
        maxCapacity,
      ];
}
