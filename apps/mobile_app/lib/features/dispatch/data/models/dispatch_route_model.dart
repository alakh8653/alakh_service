import '../../domain/entities/dispatch_location.dart';
import '../../domain/entities/dispatch_route.dart';
import 'dispatch_location_model.dart';

/// Data-layer model for [DispatchRoute] with JSON serialisation support.
class DispatchRouteModel extends DispatchRoute {
  const DispatchRouteModel({
    required super.jobId,
    required super.waypoints,
    required super.distanceMeters,
    required super.durationSeconds,
    required super.polylineEncoded,
  });

  /// Creates a [DispatchRouteModel] from a JSON map.
  factory DispatchRouteModel.fromJson(Map<String, dynamic> json) {
    final waypointsJson = json['waypoints'] as List<dynamic>;
    return DispatchRouteModel(
      jobId: json['job_id'] as String,
      waypoints: waypointsJson
          .map((e) => DispatchLocationModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      distanceMeters: (json['distance_meters'] as num).toDouble(),
      durationSeconds: (json['duration_seconds'] as num).toInt(),
      polylineEncoded: json['polyline_encoded'] as String,
    );
  }

  /// Serialises this model to a JSON map.
  Map<String, dynamic> toJson() => {
        'job_id': jobId,
        'waypoints': waypoints
            .map((w) => DispatchLocationModel.fromEntity(w).toJson())
            .toList(),
        'distance_meters': distanceMeters,
        'duration_seconds': durationSeconds,
        'polyline_encoded': polylineEncoded,
      };

  /// Creates a copy with optional field overrides.
  DispatchRouteModel copyWith({
    String? jobId,
    List<DispatchLocation>? waypoints,
    double? distanceMeters,
    int? durationSeconds,
    String? polylineEncoded,
  }) {
    return DispatchRouteModel(
      jobId: jobId ?? this.jobId,
      waypoints: waypoints ?? this.waypoints,
      distanceMeters: distanceMeters ?? this.distanceMeters,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      polylineEncoded: polylineEncoded ?? this.polylineEncoded,
    );
  }

  /// Creates a [DispatchRouteModel] from its domain [DispatchRoute] entity.
  factory DispatchRouteModel.fromEntity(DispatchRoute entity) {
    return DispatchRouteModel(
      jobId: entity.jobId,
      waypoints: entity.waypoints,
      distanceMeters: entity.distanceMeters,
      durationSeconds: entity.durationSeconds,
      polylineEncoded: entity.polylineEncoded,
    );
  }
}
