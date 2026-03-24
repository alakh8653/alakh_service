import 'package:equatable/equatable.dart';
import 'package:admin_web/features/city_management/domain/entities/city_entity.dart';

abstract class CityState extends Equatable {
  const CityState();

  @override
  List<Object?> get props => [];
}

class CityInitial extends CityState {
  const CityInitial();
}

class CitiesLoading extends CityState {
  const CitiesLoading();
}

class CitiesLoaded extends CityState {
  final List<CityEntity> cities;
  final int total;
  final String? search;
  final bool? activeFilter;

  const CitiesLoaded({
    required this.cities,
    required this.total,
    this.search,
    this.activeFilter,
  });

  @override
  List<Object?> get props => [cities, total, search, activeFilter];
}

class CityDetailLoading extends CityState {
  const CityDetailLoading();
}

class CityDetailLoaded extends CityState {
  final CityEntity city;

  const CityDetailLoaded(this.city);

  @override
  List<Object?> get props => [city];
}

class CityOperationLoading extends CityState {
  const CityOperationLoading();
}

class CityOperationSuccess extends CityState {
  final String message;

  const CityOperationSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class CityError extends CityState {
  final String message;

  const CityError(this.message);

  @override
  List<Object?> get props => [message];
}
