import 'package:equatable/equatable.dart';

import '../../domain/entities/location.dart';
import '../../domain/entities/tracking_session.dart';

/// Base class for all tracking BLoC states.
abstract class TrackingState extends Equatable {
  /// Creates a [TrackingState].
  const TrackingState();
}

/// Initial state before any tracking operation.
class TrackingInitial extends TrackingState {
  /// Creates a [TrackingInitial].
  const TrackingInitial();

  @override
  List<Object?> get props => [];
}

/// State emitted while an async tracking operation is in progress.
class TrackingLoading extends TrackingState {
  /// Creates a [TrackingLoading].
  const TrackingLoading();

  @override
  List<Object?> get props => [];
}

/// State emitted when a tracking session is active.
class TrackingActive extends TrackingState {
  /// The active tracking session.
  final TrackingSession session;

  /// Creates a [TrackingActive].
  const TrackingActive({required this.session});

  @override
  List<Object?> get props => [session];
}

/// State emitted when the tracked location has been updated.
class LocationUpdatedState extends TrackingState {
  /// The tracking session with updated location context.
  final TrackingSession session;

  /// The newly received location.
  final Location newLocation;

  /// Creates a [LocationUpdatedState].
  const LocationUpdatedState({
    required this.session,
    required this.newLocation,
  });

  @override
  List<Object?> get props => [session, newLocation];
}

/// State emitted when the tracking session has been completed.
class TrackingCompleted extends TrackingState {
  /// The completed tracking session.
  final TrackingSession session;

  /// Creates a [TrackingCompleted].
  const TrackingCompleted({required this.session});

  @override
  List<Object?> get props => [session];
}

/// State emitted when a tracking operation fails.
class TrackingError extends TrackingState {
  /// Human-readable error description.
  final String message;

  /// Creates a [TrackingError].
  const TrackingError({required this.message});

  @override
  List<Object?> get props => [message];
}
