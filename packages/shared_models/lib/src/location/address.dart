import 'package:equatable/equatable.dart';

import 'coordinates.dart';

/// Represents a physical mailing address, optionally with geographic coordinates.
class Address extends Equatable {
  /// Street name and house/building number.
  final String street;

  /// City or locality name.
  final String city;

  /// State, province, or region.
  final String state;

  /// Postal / ZIP code.
  final String zip;

  /// ISO 3166-1 alpha-2 country code or full country name.
  final String country;

  /// Optional GPS coordinates for this address.
  final Coordinates? coordinates;

  const Address({
    required this.street,
    required this.city,
    required this.state,
    required this.zip,
    required this.country,
    this.coordinates,
  });

  /// Creates an [Address] from a JSON map.
  factory Address.fromJson(Map<String, dynamic> json) => Address(
        street: json['street'] as String,
        city: json['city'] as String,
        state: json['state'] as String,
        zip: json['zip'] as String,
        country: json['country'] as String,
        coordinates: json['coordinates'] != null
            ? Coordinates.fromJson(json['coordinates'] as Map<String, dynamic>)
            : null,
      );

  /// Converts this instance to a JSON map.
  Map<String, dynamic> toJson() => {
        'street': street,
        'city': city,
        'state': state,
        'zip': zip,
        'country': country,
        if (coordinates != null) 'coordinates': coordinates!.toJson(),
      };

  /// Returns a copy with optionally overridden fields.
  Address copyWith({
    String? street,
    String? city,
    String? state,
    String? zip,
    String? country,
    Coordinates? coordinates,
  }) =>
      Address(
        street: street ?? this.street,
        city: city ?? this.city,
        state: state ?? this.state,
        zip: zip ?? this.zip,
        country: country ?? this.country,
        coordinates: coordinates ?? this.coordinates,
      );

  @override
  List<Object?> get props => [street, city, state, zip, country, coordinates];

  @override
  String toString() =>
      'Address(street: $street, city: $city, state: $state, zip: $zip, country: $country, coordinates: $coordinates)';
}
