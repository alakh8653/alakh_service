import '../../domain/entities/entities.dart';

/// Data model for [TimeSlot] that handles JSON serialisation.
class TimeSlotModel extends TimeSlot {
  const TimeSlotModel({
    required super.id,
    required super.startTime,
    required super.endTime,
    required super.isAvailable,
    super.staffId,
    super.staffName,
  });

  /// Creates a [TimeSlotModel] from a JSON [map].
  factory TimeSlotModel.fromJson(Map<String, dynamic> map) {
    return TimeSlotModel(
      id: map['id'] as String,
      startTime: DateTime.parse(map['startTime'] as String),
      endTime: DateTime.parse(map['endTime'] as String),
      isAvailable: map['isAvailable'] as bool,
      staffId: map['staffId'] as String?,
      staffName: map['staffName'] as String?,
    );
  }

  /// Serialises this model to a JSON-compatible map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'isAvailable': isAvailable,
      if (staffId != null) 'staffId': staffId,
      if (staffName != null) 'staffName': staffName,
    };
  }

  /// Creates a copy of this model with optional overridden fields.
  @override
  TimeSlotModel copyWith({
    String? id,
    DateTime? startTime,
    DateTime? endTime,
    bool? isAvailable,
    String? staffId,
    String? staffName,
  }) {
    return TimeSlotModel(
      id: id ?? this.id,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      isAvailable: isAvailable ?? this.isAvailable,
      staffId: staffId ?? this.staffId,
      staffName: staffName ?? this.staffName,
    );
  }

  /// Converts a domain [TimeSlot] entity into a [TimeSlotModel].
  factory TimeSlotModel.fromEntity(TimeSlot slot) {
    return TimeSlotModel(
      id: slot.id,
      startTime: slot.startTime,
      endTime: slot.endTime,
      isAvailable: slot.isAvailable,
      staffId: slot.staffId,
      staffName: slot.staffName,
    );
  }
}
