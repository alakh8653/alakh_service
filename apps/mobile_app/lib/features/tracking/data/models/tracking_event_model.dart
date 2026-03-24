import 'location_model.dart';

/// Represents a real-time event received from the tracking WebSocket / SSE feed.
class TrackingEventModel {
  /// The session this event belongs to.
  final String sessionId;

  /// The type of event (e.g. `location_update`, `status_change`).
  final String eventType;

  /// Location payload, present for location-related events.
  final LocationModel? location;

  /// New session status string, present for status-change events.
  final String? status;

  /// When the event was emitted by the server.
  final DateTime timestamp;

  /// Optional human-readable message attached to the event.
  final String? message;

  /// Creates a [TrackingEventModel].
  const TrackingEventModel({
    required this.sessionId,
    required this.eventType,
    this.location,
    this.status,
    required this.timestamp,
    this.message,
  });

  /// Deserialises a [TrackingEventModel] from a JSON map.
  factory TrackingEventModel.fromJson(Map<String, dynamic> json) {
    return TrackingEventModel(
      sessionId: json['session_id'] as String,
      eventType: json['event_type'] as String,
      location: json['location'] != null
          ? LocationModel.fromJson(json['location'] as Map<String, dynamic>)
          : null,
      status: json['status'] as String?,
      timestamp: DateTime.parse(json['timestamp'] as String),
      message: json['message'] as String?,
    );
  }

  /// Converts this model to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'session_id': sessionId,
      'event_type': eventType,
      if (location != null) 'location': location!.toJson(),
      if (status != null) 'status': status,
      'timestamp': timestamp.toIso8601String(),
      if (message != null) 'message': message,
    };
  }
}
