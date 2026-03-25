import '../realtime_service.dart';

class LocationUpdate {
  const LocationUpdate({
    required this.dispatchId,
    required this.latitude,
    required this.longitude,
    required this.timestamp,
  });

  final String dispatchId;
  final double latitude;
  final double longitude;
  final DateTime timestamp;

  factory LocationUpdate.fromMap(Map<String, dynamic> map) => LocationUpdate(
        dispatchId: map['dispatchId'] as String,
        latitude: (map['latitude'] as num).toDouble(),
        longitude: (map['longitude'] as num).toDouble(),
        timestamp: DateTime.parse(map['timestamp'] as String),
      );
}

class DispatchChannel {
  DispatchChannel({required RealtimeService realtimeService})
      : _service = realtimeService;

  final RealtimeService _service;

  static const String _locationUpdateEvent = 'dispatch:location';
  static const String _trackDispatchEvent = 'dispatch:track';
  static const String _untrackDispatchEvent = 'dispatch:untrack';

  Stream<LocationUpdate> get locationUpdates => _service.on<LocationUpdate>(
        _locationUpdateEvent,
        (data) => LocationUpdate.fromMap(data as Map<String, dynamic>),
      );

  void trackDispatch(String dispatchId) =>
      _service.emit(_trackDispatchEvent, {'dispatchId': dispatchId});

  void untrackDispatch(String dispatchId) =>
      _service.emit(_untrackDispatchEvent, {'dispatchId': dispatchId});

  void unsubscribe() => _service.off(_locationUpdateEvent);
}
