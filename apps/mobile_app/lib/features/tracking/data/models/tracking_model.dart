import '../../domain/entities/tracking_session.dart';
import '../../domain/entities/tracking_status.dart';
import 'location_model.dart';

/// Data-layer representation of [TrackingSession].
///
/// Adds JSON serialisation and a [copyWith] method.
class TrackingModel extends TrackingSession {
  /// Creates a [TrackingModel].
  const TrackingModel({
    required super.id,
    required super.jobId,
    required super.staffId,
    required super.customerId,
    required super.status,
    super.currentLocation,
    super.destinationLocation,
    super.eta,
    super.routePolyline,
    super.startedAt,
    required super.updatedAt,
  });

  /// Deserialises a [TrackingModel] from a JSON map.
  factory TrackingModel.fromJson(Map<String, dynamic> json) {
    return TrackingModel(
      id: json['id'] as String,
      jobId: json['job_id'] as String,
      staffId: json['staff_id'] as String,
      customerId: json['customer_id'] as String,
      status: _parseStatus(json['status'] as String),
      currentLocation: json['current_location'] != null
          ? LocationModel.fromJson(
              json['current_location'] as Map<String, dynamic>)
          : null,
      destinationLocation: json['destination_location'] != null
          ? LocationModel.fromJson(
              json['destination_location'] as Map<String, dynamic>)
          : null,
      eta: json['eta_seconds'] != null
          ? Duration(seconds: (json['eta_seconds'] as num).toInt())
          : null,
      routePolyline: json['route_polyline'] as String?,
      startedAt: json['started_at'] != null
          ? DateTime.parse(json['started_at'] as String)
          : null,
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  /// Converts this model to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'job_id': jobId,
      'staff_id': staffId,
      'customer_id': customerId,
      'status': _statusToString(status),
      if (currentLocation != null)
        'current_location':
            (currentLocation as LocationModel?)?.toJson() ??
                _locationToJson(currentLocation!),
      if (destinationLocation != null)
        'destination_location':
            (destinationLocation as LocationModel?)?.toJson() ??
                _locationToJson(destinationLocation!),
      if (eta != null) 'eta_seconds': eta!.inSeconds,
      if (routePolyline != null) 'route_polyline': routePolyline,
      if (startedAt != null) 'started_at': startedAt!.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Creates a copy of this model with the given fields replaced.
  TrackingModel copyWith({
    String? id,
    String? jobId,
    String? staffId,
    String? customerId,
    TrackingStatus? status,
    LocationModel? currentLocation,
    LocationModel? destinationLocation,
    Duration? eta,
    String? routePolyline,
    DateTime? startedAt,
    DateTime? updatedAt,
  }) {
    return TrackingModel(
      id: id ?? this.id,
      jobId: jobId ?? this.jobId,
      staffId: staffId ?? this.staffId,
      customerId: customerId ?? this.customerId,
      status: status ?? this.status,
      currentLocation: currentLocation ?? this.currentLocation,
      destinationLocation: destinationLocation ?? this.destinationLocation,
      eta: eta ?? this.eta,
      routePolyline: routePolyline ?? this.routePolyline,
      startedAt: startedAt ?? this.startedAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  static TrackingStatus _parseStatus(String value) {
    switch (value) {
      case 'staff_en_route':
        return TrackingStatus.staffEnRoute;
      case 'staff_arrived':
        return TrackingStatus.staffArrived;
      case 'service_in_progress':
        return TrackingStatus.serviceInProgress;
      case 'completed':
        return TrackingStatus.completed;
      default:
        return TrackingStatus.notStarted;
    }
  }

  static String _statusToString(TrackingStatus status) {
    switch (status) {
      case TrackingStatus.staffEnRoute:
        return 'staff_en_route';
      case TrackingStatus.staffArrived:
        return 'staff_arrived';
      case TrackingStatus.serviceInProgress:
        return 'service_in_progress';
      case TrackingStatus.completed:
        return 'completed';
      case TrackingStatus.notStarted:
        return 'not_started';
    }
  }

  static Map<String, dynamic> _locationToJson(location) => {
        'latitude': location.latitude,
        'longitude': location.longitude,
        if (location.heading != null) 'heading': location.heading,
        if (location.speed != null) 'speed': location.speed,
        if (location.accuracy != null) 'accuracy': location.accuracy,
        'timestamp': location.timestamp.toIso8601String(),
      };
}
