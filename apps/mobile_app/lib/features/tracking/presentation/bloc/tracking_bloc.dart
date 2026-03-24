import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/tracking_session.dart';
import '../../domain/entities/tracking_status.dart';
import '../../domain/usecases/get_eta_usecase.dart';
import '../../domain/usecases/get_tracking_status_usecase.dart';
import '../../domain/usecases/start_tracking_usecase.dart';
import '../../domain/usecases/stop_tracking_usecase.dart';
import '../../domain/usecases/update_location_usecase.dart';
import '../../domain/usecases/watch_live_location_usecase.dart';
import 'tracking_event.dart';
import 'tracking_state.dart';

/// BLoC that manages all tracking-related state transitions.
class TrackingBloc extends Bloc<TrackingEvent, TrackingState> {
  /// Use case for starting a tracking session.
  final StartTrackingUseCase startTrackingUseCase;

  /// Use case for stopping a tracking session.
  final StopTrackingUseCase stopTrackingUseCase;

  /// Use case for subscribing to live location updates.
  final WatchLiveLocationUseCase watchLiveLocationUseCase;

  /// Use case for fetching current session status.
  final GetTrackingStatusUseCase getTrackingStatusUseCase;

  /// Use case for pushing staff location updates.
  final UpdateLocationUseCase updateLocationUseCase;

  /// Use case for refreshing ETA.
  final GetEtaUseCase getEtaUseCase;

  /// Holds the active session for reference during location updates.
  TrackingSession? _activeSession;

  /// Creates a [TrackingBloc].
  TrackingBloc({
    required this.startTrackingUseCase,
    required this.stopTrackingUseCase,
    required this.watchLiveLocationUseCase,
    required this.getTrackingStatusUseCase,
    required this.updateLocationUseCase,
    required this.getEtaUseCase,
  }) : super(const TrackingInitial()) {
    on<StartTrackingEvent>(_onStartTracking);
    on<StopTrackingEvent>(_onStopTracking);
    on<WatchLocationEvent>(_onWatchLocation);
    on<LocationUpdatedEvent>(_onLocationUpdated);
    on<RefreshEtaEvent>(_onRefreshEta);
  }

  // ---------------------------------------------------------------------------
  // Event handlers
  // ---------------------------------------------------------------------------

  Future<void> _onStartTracking(
    StartTrackingEvent event,
    Emitter<TrackingState> emit,
  ) async {
    emit(const TrackingLoading());
    final result = await startTrackingUseCase(
      StartTrackingParams(jobId: event.jobId),
    );
    result.fold(
      (failure) => emit(TrackingError(message: failure.message)),
      (session) {
        _activeSession = session;
        emit(TrackingActive(session: session));
        add(WatchLocationEvent(sessionId: session.id));
      },
    );
  }

  Future<void> _onStopTracking(
    StopTrackingEvent event,
    Emitter<TrackingState> emit,
  ) async {
    emit(const TrackingLoading());
    final result = await stopTrackingUseCase(
      StopTrackingParams(sessionId: event.sessionId),
    );
    result.fold(
      (failure) => emit(TrackingError(message: failure.message)),
      (_) {
        final session = _activeSession;
        _activeSession = null;
        if (session != null) {
          emit(TrackingCompleted(session: session));
        } else {
          emit(const TrackingInitial());
        }
      },
    );
  }

  Future<void> _onWatchLocation(
    WatchLocationEvent event,
    Emitter<TrackingState> emit,
  ) async {
    final stream = watchLiveLocationUseCase(
      WatchLiveLocationParams(sessionId: event.sessionId),
    );

    // emit.forEach properly handles stream lifecycle and cancellation.
    await emit.forEach(
      stream,
      onData: (data) {
        return data.fold(
          (failure) => TrackingError(message: failure.message),
          (location) {
            final session = _activeSession;
            if (session == null) {
              return TrackingError(message: 'No active session');
            }
            return LocationUpdatedState(
              session: session,
              newLocation: location,
            );
          },
        );
      },
      onError: (error, _) => TrackingError(message: error.toString()),
    );
  }

  Future<void> _onLocationUpdated(
    LocationUpdatedEvent event,
    Emitter<TrackingState> emit,
  ) async {
    final result = await updateLocationUseCase(
      UpdateLocationParams(
        sessionId: event.sessionId,
        location: event.location,
      ),
    );
    result.fold(
      (failure) => emit(TrackingError(message: failure.message)),
      (_) {
        // Silently succeed; the stream will deliver the reflected update.
      },
    );
  }

  Future<void> _onRefreshEta(
    RefreshEtaEvent event,
    Emitter<TrackingState> emit,
  ) async {
    final result = await getEtaUseCase(
      GetEtaParams(sessionId: event.sessionId),
    );
    result.fold(
      (failure) => emit(TrackingError(message: failure.message)),
      (eta) {
        final session = _activeSession;
        if (session == null) return;
        // Refresh the full session status to pick up the new ETA.
        add(WatchLocationEvent(sessionId: session.id));
      },
    );
  }
}
