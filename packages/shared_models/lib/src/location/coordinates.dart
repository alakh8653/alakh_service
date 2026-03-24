import 'package:equatable/equatable.dart';

/// Represents a geographic point on Earth using WGS-84 decimal degrees.
class Coordinates extends Equatable {
  /// Latitude in decimal degrees (–90 to +90).
  final double latitude;

  /// Longitude in decimal degrees (–180 to +180).
  final double longitude;

  const Coordinates({
    required this.latitude,
    required this.longitude,
  });

  /// Creates a [Coordinates] instance from a JSON map.
  factory Coordinates.fromJson(Map<String, dynamic> json) => Coordinates(
        latitude: (json['latitude'] as num).toDouble(),
        longitude: (json['longitude'] as num).toDouble(),
      );

  /// Converts this instance to a JSON map.
  Map<String, dynamic> toJson() => {
        'latitude': latitude,
        'longitude': longitude,
      };

  /// Returns a copy of this instance with optionally overridden fields.
  Coordinates copyWith({
    double? latitude,
    double? longitude,
  }) =>
      Coordinates(
        latitude: latitude ?? this.latitude,
        longitude: longitude ?? this.longitude,
      );

  @override
  List<Object?> get props => [latitude, longitude];

  @override
  String toString() => 'Coordinates(latitude: $latitude, longitude: $longitude)';
}
