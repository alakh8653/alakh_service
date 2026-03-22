import 'package:equatable/equatable.dart';
import 'dispatch_location.dart';

/// Domain entity representing a navigable route for a dispatch job.
class DispatchRoute extends Equatable {
  /// Job identifier this route belongs to.
  final String jobId;

  /// Ordered list of waypoints along the route.
  final List<DispatchLocation> waypoints;

  /// Total route distance in metres.
  final double distanceMeters;

  /// Estimated travel time in seconds.
  final int durationSeconds;

  /// Google Maps / Mapbox encoded polyline string for the route.
  final String polylineEncoded;

  const DispatchRoute({
    required this.jobId,
    required this.waypoints,
    required this.distanceMeters,
    required this.durationSeconds,
    required this.polylineEncoded,
  });

  /// Convenience getter: distance in kilometres.
  double get distanceKm => distanceMeters / 1000.0;

  /// Convenience getter: duration as a [Duration].
  Duration get duration => Duration(seconds: durationSeconds);

  @override
  List<Object?> get props => [jobId, waypoints, distanceMeters, durationSeconds, polylineEncoded];
}
