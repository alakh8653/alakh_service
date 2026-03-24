import 'package:equatable/equatable.dart';

class CityEntity extends Equatable {
  final String id;
  final String name;
  final String state;
  final String country;
  final double latitude;
  final double longitude;
  final double radius;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int shopCount;
  final int userCount;
  final List<String> serviceZones;

  const CityEntity({
    required this.id,
    required this.name,
    required this.state,
    required this.country,
    required this.latitude,
    required this.longitude,
    required this.radius,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    required this.shopCount,
    required this.userCount,
    required this.serviceZones,
  });

  CityEntity copyWith({
    String? id,
    String? name,
    String? state,
    String? country,
    double? latitude,
    double? longitude,
    double? radius,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? shopCount,
    int? userCount,
    List<String>? serviceZones,
  }) {
    return CityEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      state: state ?? this.state,
      country: country ?? this.country,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      radius: radius ?? this.radius,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      shopCount: shopCount ?? this.shopCount,
      userCount: userCount ?? this.userCount,
      serviceZones: serviceZones ?? this.serviceZones,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        state,
        country,
        latitude,
        longitude,
        radius,
        isActive,
        createdAt,
        updatedAt,
        shopCount,
        userCount,
        serviceZones,
      ];
}
