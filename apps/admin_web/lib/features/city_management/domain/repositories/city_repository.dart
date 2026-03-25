import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:admin_web/core/core.dart';
import 'package:admin_web/features/city_management/domain/entities/city_entity.dart';

class CreateCityParams extends Equatable {
  final String name;
  final String state;
  final String country;
  final double latitude;
  final double longitude;
  final double radius;
  final List<String> serviceZones;

  const CreateCityParams({
    required this.name,
    required this.state,
    this.country = 'India',
    required this.latitude,
    required this.longitude,
    required this.radius,
    this.serviceZones = const [],
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'state': state,
        'country': country,
        'latitude': latitude,
        'longitude': longitude,
        'radius': radius,
        'serviceZones': serviceZones,
      };

  @override
  List<Object?> get props => [name, state, country, latitude, longitude, radius, serviceZones];
}

class UpdateCityParams extends Equatable {
  final String? name;
  final String? state;
  final String? country;
  final double? latitude;
  final double? longitude;
  final double? radius;
  final List<String>? serviceZones;

  const UpdateCityParams({
    this.name,
    this.state,
    this.country,
    this.latitude,
    this.longitude,
    this.radius,
    this.serviceZones,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (name != null) map['name'] = name;
    if (state != null) map['state'] = state;
    if (country != null) map['country'] = country;
    if (latitude != null) map['latitude'] = latitude;
    if (longitude != null) map['longitude'] = longitude;
    if (radius != null) map['radius'] = radius;
    if (serviceZones != null) map['serviceZones'] = serviceZones;
    return map;
  }

  @override
  List<Object?> get props => [name, state, country, latitude, longitude, radius, serviceZones];
}

abstract class CityRepository {
  Future<Either<Failure, List<CityEntity>>> getCities({
    String? search,
    bool? active,
  });

  Future<Either<Failure, CityEntity>> getCityById(String id);

  Future<Either<Failure, CityEntity>> createCity(CreateCityParams params);

  Future<Either<Failure, CityEntity>> updateCity(String id, UpdateCityParams params);

  Future<Either<Failure, Unit>> deleteCity(String id);

  Future<Either<Failure, CityEntity>> toggleCityStatus(String id, bool active);
}
