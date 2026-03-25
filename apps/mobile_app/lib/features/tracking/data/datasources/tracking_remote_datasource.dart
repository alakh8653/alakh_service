import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';

import '../../../../core/error/failures.dart';
import '../models/location_model.dart';
import '../models/tracking_event_model.dart';
import '../models/tracking_model.dart';

/// Abstract contract for remote tracking data operations.
abstract class TrackingRemoteDataSource {
  /// Starts a new tracking session for [jobId].
  Future<TrackingModel> startTracking(String jobId);

  /// Stops the session identified by [sessionId].
  Future<void> stopTracking(String sessionId);

  /// Fetches the current state of [sessionId].
  Future<TrackingModel> getTrackingStatus(String sessionId);

  /// Pushes a location update for [sessionId].
  Future<void> updateLocation(String sessionId, LocationModel location);

  /// Returns the server-computed ETA in seconds for [sessionId].
  Future<int> getEta(String sessionId);

  /// Returns a stream of real-time [TrackingEventModel] for [sessionId].
  ///
  /// The current implementation polls the REST endpoint.
  /// TODO: replace with a WebSocket / SSE connection for true real-time updates.
  Stream<TrackingEventModel> watchLiveLocation(String sessionId);
}

/// Concrete [TrackingRemoteDataSource] backed by the REST API via [Dio].
class TrackingRemoteDataSourceImpl implements TrackingRemoteDataSource {
  /// The Dio HTTP client.
  final Dio dio;

  /// How often the polling stream refreshes.
  final Duration _pollInterval;

  /// Creates a [TrackingRemoteDataSourceImpl].
  TrackingRemoteDataSourceImpl({
    required this.dio,
    Duration pollInterval = const Duration(seconds: 5),
  }) : _pollInterval = pollInterval;

  // ---------------------------------------------------------------------------
  // Start tracking
  // ---------------------------------------------------------------------------

  @override
  Future<TrackingModel> startTracking(String jobId) async {
    try {
      final response = await dio.post<Map<String, dynamic>>(
        '/api/v1/tracking/start',
        data: {'job_id': jobId},
      );
      return TrackingModel.fromJson(response.data!);
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  // ---------------------------------------------------------------------------
  // Stop tracking
  // ---------------------------------------------------------------------------

  @override
  Future<void> stopTracking(String sessionId) async {
    try {
      await dio.post<void>('/api/v1/tracking/$sessionId/stop');
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  // ---------------------------------------------------------------------------
  // Get tracking status
  // ---------------------------------------------------------------------------

  @override
  Future<TrackingModel> getTrackingStatus(String sessionId) async {
    try {
      final response = await dio.get<Map<String, dynamic>>(
        '/api/v1/tracking/$sessionId',
      );
      return TrackingModel.fromJson(response.data!);
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  // ---------------------------------------------------------------------------
  // Update location
  // ---------------------------------------------------------------------------

  @override
  Future<void> updateLocation(String sessionId, LocationModel location) async {
    try {
      await dio.patch<void>(
        '/api/v1/tracking/$sessionId/location',
        data: location.toJson(),
      );
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  // ---------------------------------------------------------------------------
  // Get ETA
  // ---------------------------------------------------------------------------

  @override
  Future<int> getEta(String sessionId) async {
    try {
      final response = await dio.get<Map<String, dynamic>>(
        '/api/v1/tracking/$sessionId/eta',
      );
      return (response.data!['eta_seconds'] as num).toInt();
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  // ---------------------------------------------------------------------------
  // Watch live location (polling)
  // ---------------------------------------------------------------------------

  @override
  Stream<TrackingEventModel> watchLiveLocation(String sessionId) async* {
    // TODO: Replace polling with a WebSocket or SSE connection.
    while (true) {
      try {
        final response = await dio.get<Map<String, dynamic>>(
          '/api/v1/tracking/$sessionId/live',
        );
        yield TrackingEventModel.fromJson(response.data!);
      } on DioException catch (e) {
        throw _mapDioError(e);
      }
      await Future<void>.delayed(_pollInterval);
    }
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  Failure _mapDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionError:
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        return NetworkFailure(cause: e);
      default:
        final statusCode = e.response?.statusCode;
        if (statusCode == 401) {
          return UnauthorisedFailure(cause: e);
        }
        if (statusCode == 404) {
          return NotFoundFailure(cause: e);
        }
        return ServerFailure(
          message: e.response?.statusMessage ?? e.message ?? 'Server error',
          statusCode: statusCode,
          cause: e,
        );
    }
  }
}
