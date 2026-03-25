import '../../domain/entities/location.dart';

/// Data-layer representation of [Location].
///
/// Adds JSON serialisation and a [copyWith] method.
class LocationModel extends Location {
  /// Creates a [LocationModel].
  const LocationModel({
    required super.latitude,
    required super.longitude,
    super.heading,
    super.speed,
    super.accuracy,
    required super.timestamp,
  });

  /// Deserialises a [LocationModel] from a JSON map.
  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      heading: (json['heading'] as num?)?.toDouble(),
      speed: (json['speed'] as num?)?.toDouble(),
      accuracy: (json['accuracy'] as num?)?.toDouble(),
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  /// Converts this model to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      if (heading != null) 'heading': heading,
      if (speed != null) 'speed': speed,
      if (accuracy != null) 'accuracy': accuracy,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  /// Creates a copy of this model with the given fields replaced.
  LocationModel copyWith({
    double? latitude,
    double? longitude,
    double? heading,
    double? speed,
    double? accuracy,
    DateTime? timestamp,
  }) {
    return LocationModel(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      heading: heading ?? this.heading,
      speed: speed ?? this.speed,
      accuracy: accuracy ?? this.accuracy,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  /// Converts a domain [Location] to a [LocationModel].
  factory LocationModel.fromEntity(Location location) {
    return LocationModel(
      latitude: location.latitude,
      longitude: location.longitude,
      heading: location.heading,
      speed: location.speed,
      accuracy: location.accuracy,
      timestamp: location.timestamp,
    );
  }
}
