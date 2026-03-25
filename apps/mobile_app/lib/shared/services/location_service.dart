/// GPS location service with permission handling.
library;

// TODO: Add `geolocator` and `permission_handler` packages to pubspec.yaml.

/// A device position snapshot.
class AppPosition {
  const AppPosition({
    required this.latitude,
    required this.longitude,
    this.accuracy,
    this.altitude,
    this.speed,
    this.heading,
    this.timestamp,
  });

  final double latitude;
  final double longitude;

  /// Horizontal accuracy in metres.
  final double? accuracy;

  /// Altitude in metres above sea level.
  final double? altitude;

  /// Speed in metres per second.
  final double? speed;

  /// Compass heading in degrees (0–360).
  final double? heading;

  final DateTime? timestamp;

  @override
  String toString() =>
      'AppPosition(lat: $latitude, lng: $longitude)';
}

/// Possible states for location permission.
enum LocationPermissionStatus {
  granted,
  denied,
  deniedForever,
  restricted,
}

/// Provides GPS location and permission management.
///
/// ### Usage:
/// ```dart
/// final service = LocationService.instance;
/// final status = await service.requestPermission();
/// if (status == LocationPermissionStatus.granted) {
///   final pos = await service.getCurrentPosition();
/// }
/// ```
class LocationService {
  LocationService._();
  static final LocationService instance = LocationService._();

  /// Checks whether location services are enabled on the device.
  Future<bool> isLocationServiceEnabled() async {
    // TODO: return await Geolocator.isLocationServiceEnabled();
    throw UnimplementedError('Add geolocator and implement.');
  }

  /// Requests location permission from the user.
  Future<LocationPermissionStatus> requestPermission() async {
    // TODO:
    // final permission = await Geolocator.requestPermission();
    // switch (permission) {
    //   case LocationPermission.always:
    //   case LocationPermission.whileInUse: return LocationPermissionStatus.granted;
    //   case LocationPermission.denied: return LocationPermissionStatus.denied;
    //   case LocationPermission.deniedForever: return LocationPermissionStatus.deniedForever;
    //   default: return LocationPermissionStatus.denied;
    // }
    throw UnimplementedError('Add geolocator and implement.');
  }

  /// Returns the current device position.
  ///
  /// Throws if permission is not granted or services are disabled.
  Future<AppPosition> getCurrentPosition() async {
    // TODO:
    // final pos = await Geolocator.getCurrentPosition(
    //   desiredAccuracy: LocationAccuracy.high,
    // );
    // return AppPosition(
    //   latitude: pos.latitude,
    //   longitude: pos.longitude,
    //   accuracy: pos.accuracy,
    //   altitude: pos.altitude,
    //   speed: pos.speed,
    //   heading: pos.heading,
    //   timestamp: pos.timestamp,
    // );
    throw UnimplementedError('Add geolocator and implement.');
  }

  /// Returns a stream of position updates.
  Stream<AppPosition> positionStream() {
    // TODO:
    // return Geolocator.getPositionStream(
    //   locationSettings: const LocationSettings(
    //     accuracy: LocationAccuracy.high,
    //     distanceFilter: 10,
    //   ),
    // ).map((pos) => AppPosition(...));
    throw UnimplementedError('Add geolocator and implement.');
  }

  /// Calculates the distance (in metres) between two positions.
  double distanceBetween(
    AppPosition from,
    AppPosition to,
  ) {
    // TODO: return Geolocator.distanceBetween(
    //   from.latitude, from.longitude, to.latitude, to.longitude);
    throw UnimplementedError('Add geolocator and implement.');
  }
}
