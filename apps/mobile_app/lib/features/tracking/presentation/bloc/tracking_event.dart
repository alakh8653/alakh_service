import 'package:equatable/equatable.dart';

import '../../domain/entities/location.dart';

/// Base class for all tracking BLoC events.
abstract class TrackingEvent extends Equatable {
  /// Creates a [TrackingEvent].
  const TrackingEvent();
}

/// Event to start a new tracking session for [jobId].
class StartTrackingEvent extends TrackingEvent {
  /// The job to start tracking for.
  final String jobId;

  /// Creates a [StartTrackingEvent].
  const StartTrackingEvent({required this.jobId});

  @override
  List<Object?> get props => [jobId];
}

/// Event to stop the tracking session identified by [sessionId].
class StopTrackingEvent extends TrackingEvent {
  /// The session to stop.
  final String sessionId;

  /// Creates a [StopTrackingEvent].
  const StopTrackingEvent({required this.sessionId});

  @override
  List<Object?> get props => [sessionId];
}

/// Event emitted when a new location for [sessionId] is received.
class LocationUpdatedEvent extends TrackingEvent {
  /// The session that received the update.
  final String sessionId;

  /// The new location.
  final Location location;

  /// Creates a [LocationUpdatedEvent].
  const LocationUpdatedEvent({
    required this.sessionId,
    required this.location,
  });

  @override
  List<Object?> get props => [sessionId, location];
}

/// Event to subscribe to live location updates for [sessionId].
class WatchLocationEvent extends TrackingEvent {
  /// The session to watch.
  final String sessionId;

  /// Creates a [WatchLocationEvent].
  const WatchLocationEvent({required this.sessionId});

  @override
  List<Object?> get props => [sessionId];
}

/// Event to refresh the ETA for [sessionId].
class RefreshEtaEvent extends TrackingEvent {
  /// The session whose ETA should be refreshed.
  final String sessionId;

  /// Creates a [RefreshEtaEvent].
  const RefreshEtaEvent({required this.sessionId});

  @override
  List<Object?> get props => [sessionId];
}
