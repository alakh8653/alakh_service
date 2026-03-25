import '../../domain/entities/dispatch_job.dart';
import '../../domain/entities/dispatch_location.dart';
import '../../domain/entities/dispatch_status.dart';
import 'dispatch_location_model.dart';

/// Data-layer model for [DispatchJob] with JSON serialisation support.
class DispatchJobModel extends DispatchJob {
  const DispatchJobModel({
    required super.id,
    required super.bookingId,
    required super.staffId,
    required super.customerId,
    required super.status,
    required super.pickupLocation,
    required super.dropoffLocation,
    required super.distance,
    required super.estimatedDuration,
    required super.fare,
    super.notes,
    required super.createdAt,
  });

  /// Creates a [DispatchJobModel] from a JSON map.
  ///
  /// Expects [estimated_duration_seconds] as an integer and
  /// [created_at] as an ISO-8601 string.
  factory DispatchJobModel.fromJson(Map<String, dynamic> json) {
    return DispatchJobModel(
      id: json['id'] as String,
      bookingId: json['booking_id'] as String,
      staffId: json['staff_id'] as String,
      customerId: json['customer_id'] as String,
      status: DispatchStatusX.fromString(json['status'] as String),
      pickupLocation: DispatchLocationModel.fromJson(
        json['pickup_location'] as Map<String, dynamic>,
      ),
      dropoffLocation: DispatchLocationModel.fromJson(
        json['dropoff_location'] as Map<String, dynamic>,
      ),
      distance: (json['distance'] as num).toDouble(),
      estimatedDuration: Duration(
        seconds: (json['estimated_duration_seconds'] as num).toInt(),
      ),
      fare: (json['fare'] as num).toDouble(),
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  /// Serialises this model to a JSON map.
  Map<String, dynamic> toJson() => {
        'id': id,
        'booking_id': bookingId,
        'staff_id': staffId,
        'customer_id': customerId,
        'status': status.name,
        'pickup_location': DispatchLocationModel.fromEntity(pickupLocation).toJson(),
        'dropoff_location': DispatchLocationModel.fromEntity(dropoffLocation).toJson(),
        'distance': distance,
        'estimated_duration_seconds': estimatedDuration.inSeconds,
        'fare': fare,
        'notes': notes,
        'created_at': createdAt.toIso8601String(),
      };

  /// Creates a copy with optional field overrides.
  DispatchJobModel copyWith({
    String? id,
    String? bookingId,
    String? staffId,
    String? customerId,
    DispatchStatus? status,
    DispatchLocation? pickupLocation,
    DispatchLocation? dropoffLocation,
    double? distance,
    Duration? estimatedDuration,
    double? fare,
    String? notes,
    DateTime? createdAt,
  }) {
    return DispatchJobModel(
      id: id ?? this.id,
      bookingId: bookingId ?? this.bookingId,
      staffId: staffId ?? this.staffId,
      customerId: customerId ?? this.customerId,
      status: status ?? this.status,
      pickupLocation: pickupLocation ?? this.pickupLocation,
      dropoffLocation: dropoffLocation ?? this.dropoffLocation,
      distance: distance ?? this.distance,
      estimatedDuration: estimatedDuration ?? this.estimatedDuration,
      fare: fare ?? this.fare,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Creates a [DispatchJobModel] from its domain [DispatchJob] entity.
  factory DispatchJobModel.fromEntity(DispatchJob entity) {
    return DispatchJobModel(
      id: entity.id,
      bookingId: entity.bookingId,
      staffId: entity.staffId,
      customerId: entity.customerId,
      status: entity.status,
      pickupLocation: entity.pickupLocation,
      dropoffLocation: entity.dropoffLocation,
      distance: entity.distance,
      estimatedDuration: entity.estimatedDuration,
      fare: entity.fare,
      notes: entity.notes,
      createdAt: entity.createdAt,
    );
  }
}
