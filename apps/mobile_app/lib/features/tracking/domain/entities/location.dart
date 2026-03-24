import 'dart:math' as math;
import 'package:equatable/equatable.dart';

/// Represents a geographic coordinate with optional motion metadata.
class Location extends Equatable {
  /// Latitude in decimal degrees.
  final double latitude;
  /// Longitude in decimal degrees.
  final double longitude;
  /// Heading in degrees (0–360), north-up. Null when stationary.
  final double? heading;
  /// Speed in metres per second. Null when unavailable.
  final double? speed;
  /// Horizontal accuracy in metres. Null when unavailable.
  final double? accuracy;
  /// When this coordinate was recorded.
  final DateTime timestamp;

  /// Creates a [Location].
  const Location({
    required this.latitude,
    required this.longitude,
    this.heading,
    this.speed,
    this.accuracy,
    required this.timestamp,
  });

  /// Returns the distance in metres between this location and [other]
  /// using the Haversine formula.
  double distanceTo(Location other) {
    const double earthRadiusM = 6371000;
    final double dLat = _toRadians(other.latitude - latitude);
    final double dLon = _toRadians(other.longitude - longitude);
    final double a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_toRadians(latitude)) *
            math.cos(_toRadians(other.latitude)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    final double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadiusM * c;
  }

  double _toRadians(double degrees) => degrees * math.pi / 180;

  @override
  List<Object?> get props =>
      [latitude, longitude, heading, speed, accuracy, timestamp];
}
