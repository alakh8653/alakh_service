import 'package:equatable/equatable.dart';

/// A lightweight location value object used in dispatch entities.
///
/// Avoids dependency on any maps SDK.
class DispatchLocation extends Equatable {
  /// Latitude in decimal degrees.
  final double lat;

  /// Longitude in decimal degrees.
  final double lng;

  /// Human-readable address string.
  final String address;

  const DispatchLocation({
    required this.lat,
    required this.lng,
    required this.address,
  });

  @override
  List<Object?> get props => [lat, lng, address];
}
