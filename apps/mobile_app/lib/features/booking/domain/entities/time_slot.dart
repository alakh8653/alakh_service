import 'package:equatable/equatable.dart';

/// Domain entity representing an available (or unavailable) time slot.
class TimeSlot extends Equatable {
  /// Unique identifier of the time slot.
  final String id;

  /// Start time of the slot.
  final DateTime startTime;

  /// End time of the slot.
  final DateTime endTime;

  /// Whether this slot can still be booked.
  final bool isAvailable;

  /// Optional identifier of the staff assigned to this slot.
  final String? staffId;

  /// Optional display name of the staff assigned to this slot.
  final String? staffName;

  const TimeSlot({
    required this.id,
    required this.startTime,
    required this.endTime,
    required this.isAvailable,
    this.staffId,
    this.staffName,
  });

  @override
  List<Object?> get props => [id, startTime, endTime, isAvailable, staffId, staffName];

  /// Creates a copy of this time slot with optional overridden fields.
  TimeSlot copyWith({
    String? id,
    DateTime? startTime,
    DateTime? endTime,
    bool? isAvailable,
    String? staffId,
    String? staffName,
  }) {
    return TimeSlot(
      id: id ?? this.id,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      isAvailable: isAvailable ?? this.isAvailable,
      staffId: staffId ?? this.staffId,
      staffName: staffName ?? this.staffName,
    );
  }
}
