import '../../domain/entities/dispatch_location.dart';

/// Data-layer model for [DispatchLocation] with JSON serialisation support.
class DispatchLocationModel extends DispatchLocation {
  const DispatchLocationModel({
    required super.lat,
    required super.lng,
    required super.address,
  });

  /// Creates a [DispatchLocationModel] from a JSON map.
  factory DispatchLocationModel.fromJson(Map<String, dynamic> json) {
    return DispatchLocationModel(
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
      address: json['address'] as String,
    );
  }

  /// Serialises this model to a JSON map.
  Map<String, dynamic> toJson() => {
        'lat': lat,
        'lng': lng,
        'address': address,
      };

  /// Creates a copy with optional overrides.
  DispatchLocationModel copyWith({
    double? lat,
    double? lng,
    String? address,
  }) {
    return DispatchLocationModel(
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      address: address ?? this.address,
    );
  }

  /// Creates a [DispatchLocationModel] from its domain entity counterpart.
  factory DispatchLocationModel.fromEntity(DispatchLocation entity) {
    return DispatchLocationModel(
      lat: entity.lat,
      lng: entity.lng,
      address: entity.address,
    );
  }
}
