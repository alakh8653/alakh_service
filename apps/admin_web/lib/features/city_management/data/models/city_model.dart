import 'package:admin_web/features/city_management/domain/entities/city_entity.dart';

class CityModel {
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

  const CityModel({
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

  factory CityModel.fromJson(Map<String, dynamic> json) {
    return CityModel(
      id: json['id'] as String,
      name: json['name'] as String,
      state: json['state'] as String,
      country: json['country'] as String? ?? 'India',
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      radius: (json['radius'] as num).toDouble(),
      isActive: json['isActive'] as bool? ?? json['is_active'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String? ?? json['created_at'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String? ?? json['updated_at'] as String),
      shopCount: json['shopCount'] as int? ?? json['shop_count'] as int? ?? 0,
      userCount: json['userCount'] as int? ?? json['user_count'] as int? ?? 0,
      serviceZones: (json['serviceZones'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'state': state,
        'country': country,
        'latitude': latitude,
        'longitude': longitude,
        'radius': radius,
        'isActive': isActive,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'shopCount': shopCount,
        'userCount': userCount,
        'serviceZones': serviceZones,
      };

  CityEntity toEntity() => CityEntity(
        id: id,
        name: name,
        state: state,
        country: country,
        latitude: latitude,
        longitude: longitude,
        radius: radius,
        isActive: isActive,
        createdAt: createdAt,
        updatedAt: updatedAt,
        shopCount: shopCount,
        userCount: userCount,
        serviceZones: serviceZones,
      );
}
