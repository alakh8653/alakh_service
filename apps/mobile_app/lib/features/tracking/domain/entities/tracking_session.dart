import 'package:equatable/equatable.dart';

import 'location.dart';
import 'tracking_status.dart';

/// Represents an active or historical tracking session between a customer
/// and an assigned staff member.
class TrackingSession extends Equatable {
  /// Unique session identifier.
  final String id;
  /// The job this session is associated with.
  final String jobId;
  /// The staff member being tracked.
  final String staffId;
  /// The customer who requested the service.
  final String customerId;
  /// Current status of the session.
  final TrackingStatus status;
  /// The staff member's most recent known location.
  final Location? currentLocation;
  /// The destination (customer) location.
  final Location? destinationLocation;
  /// Estimated time of arrival. Null until calculated.
  final Duration? eta;
  /// Encoded polyline for the route. Null until computed.
  final String? routePolyline;
  /// When the session was first started. Null if not yet started.
  final DateTime? startedAt;
  /// When the session was last updated.
  final DateTime updatedAt;

  /// Creates a [TrackingSession].
  const TrackingSession({
    required this.id,
    required this.jobId,
    required this.staffId,
    required this.customerId,
    required this.status,
    this.currentLocation,
    this.destinationLocation,
    this.eta,
    this.routePolyline,
    this.startedAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        jobId,
        staffId,
        customerId,
        status,
        currentLocation,
        destinationLocation,
        eta,
        routePolyline,
        startedAt,
        updatedAt,
      ];
}
