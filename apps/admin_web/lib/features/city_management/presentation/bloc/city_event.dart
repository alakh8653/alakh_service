import 'package:equatable/equatable.dart';
import 'package:admin_web/features/city_management/domain/repositories/city_repository.dart';

abstract class CityEvent extends Equatable {
  const CityEvent();

  @override
  List<Object?> get props => [];
}

class LoadCities extends CityEvent {
  final String? search;
  final bool? active;

  const LoadCities({this.search, this.active});

  @override
  List<Object?> get props => [search, active];
}

class LoadCityById extends CityEvent {
  final String id;

  const LoadCityById(this.id);

  @override
  List<Object?> get props => [id];
}

class CreateCityEvent extends CityEvent {
  final CreateCityParams params;

  const CreateCityEvent(this.params);

  @override
  List<Object?> get props => [params];
}

class UpdateCityEvent extends CityEvent {
  final String id;
  final UpdateCityParams params;

  const UpdateCityEvent(this.id, this.params);

  @override
  List<Object?> get props => [id, params];
}

class DeleteCityEvent extends CityEvent {
  final String id;

  const DeleteCityEvent(this.id);

  @override
  List<Object?> get props => [id];
}

class ToggleCityStatusEvent extends CityEvent {
  final String id;
  final bool active;

  const ToggleCityStatusEvent(this.id, this.active);

  @override
  List<Object?> get props => [id, active];
}

class SearchCities extends CityEvent {
  final String query;

  const SearchCities(this.query);

  @override
  List<Object?> get props => [query];
}

class FilterCities extends CityEvent {
  final bool? active;

  const FilterCities(this.active);

  @override
  List<Object?> get props => [active];
}
