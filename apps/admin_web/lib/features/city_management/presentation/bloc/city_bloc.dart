import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:admin_web/features/city_management/domain/usecases/get_cities.dart';
import 'package:admin_web/features/city_management/domain/usecases/get_city_by_id.dart';
import 'package:admin_web/features/city_management/domain/usecases/create_city.dart';
import 'package:admin_web/features/city_management/domain/usecases/update_city.dart';
import 'package:admin_web/features/city_management/domain/usecases/delete_city.dart';
import 'package:admin_web/features/city_management/domain/usecases/toggle_city_status.dart';
import 'package:admin_web/features/city_management/presentation/bloc/city_event.dart';
import 'package:admin_web/features/city_management/presentation/bloc/city_state.dart';

class CityBloc extends Bloc<CityEvent, CityState> {
  final GetCities _getCities;
  final GetCityById _getCityById;
  final CreateCity _createCity;
  final UpdateCity _updateCity;
  final DeleteCity _deleteCity;
  final ToggleCityStatus _toggleCityStatus;

  String? _currentSearch;
  bool? _currentActiveFilter;

  CityBloc({
    required GetCities getCities,
    required GetCityById getCityById,
    required CreateCity createCity,
    required UpdateCity updateCity,
    required DeleteCity deleteCity,
    required ToggleCityStatus toggleCityStatus,
  })  : _getCities = getCities,
        _getCityById = getCityById,
        _createCity = createCity,
        _updateCity = updateCity,
        _deleteCity = deleteCity,
        _toggleCityStatus = toggleCityStatus,
        super(const CityInitial()) {
    on<LoadCities>(_onLoadCities);
    on<LoadCityById>(_onLoadCityById);
    on<CreateCityEvent>(_onCreateCity);
    on<UpdateCityEvent>(_onUpdateCity);
    on<DeleteCityEvent>(_onDeleteCity);
    on<ToggleCityStatusEvent>(_onToggleCityStatus);
    on<SearchCities>(_onSearchCities);
    on<FilterCities>(_onFilterCities);
  }

  Future<void> _onLoadCities(LoadCities event, Emitter<CityState> emit) async {
    _currentSearch = event.search;
    _currentActiveFilter = event.active;
    emit(const CitiesLoading());
    final result = await _getCities(
      GetCitiesParams(search: event.search, active: event.active),
    );
    result.fold(
      (failure) => emit(CityError(failure.message)),
      (cities) => emit(CitiesLoaded(
        cities: cities,
        total: cities.length,
        search: event.search,
        activeFilter: event.active,
      )),
    );
  }

  Future<void> _onLoadCityById(LoadCityById event, Emitter<CityState> emit) async {
    emit(const CityDetailLoading());
    final result = await _getCityById(CityIdParams(event.id));
    result.fold(
      (failure) => emit(CityError(failure.message)),
      (city) => emit(CityDetailLoaded(city)),
    );
  }

  Future<void> _onCreateCity(CreateCityEvent event, Emitter<CityState> emit) async {
    emit(const CityOperationLoading());
    final result = await _createCity(event.params);
    result.fold(
      (failure) => emit(CityError(failure.message)),
      (_) => emit(const CityOperationSuccess('City created successfully')),
    );
  }

  Future<void> _onUpdateCity(UpdateCityEvent event, Emitter<CityState> emit) async {
    emit(const CityOperationLoading());
    final result = await _updateCity(
      UpdateCityUseCaseParams(id: event.id, params: event.params),
    );
    result.fold(
      (failure) => emit(CityError(failure.message)),
      (_) => emit(const CityOperationSuccess('City updated successfully')),
    );
  }

  Future<void> _onDeleteCity(DeleteCityEvent event, Emitter<CityState> emit) async {
    emit(const CityOperationLoading());
    final result = await _deleteCity(CityIdParams(event.id));
    result.fold(
      (failure) => emit(CityError(failure.message)),
      (_) => emit(const CityOperationSuccess('City deleted successfully')),
    );
  }

  Future<void> _onToggleCityStatus(
      ToggleCityStatusEvent event, Emitter<CityState> emit) async {
    emit(const CityOperationLoading());
    final result = await _toggleCityStatus(
      ToggleCityStatusParams(id: event.id, active: event.active),
    );
    result.fold(
      (failure) => emit(CityError(failure.message)),
      (_) => emit(CityOperationSuccess(
        event.active ? 'City activated successfully' : 'City deactivated successfully',
      )),
    );
  }

  Future<void> _onSearchCities(SearchCities event, Emitter<CityState> emit) async {
    _currentSearch = event.query.isEmpty ? null : event.query;
    emit(const CitiesLoading());
    final result = await _getCities(
      GetCitiesParams(search: _currentSearch, active: _currentActiveFilter),
    );
    result.fold(
      (failure) => emit(CityError(failure.message)),
      (cities) => emit(CitiesLoaded(
        cities: cities,
        total: cities.length,
        search: _currentSearch,
        activeFilter: _currentActiveFilter,
      )),
    );
  }

  Future<void> _onFilterCities(FilterCities event, Emitter<CityState> emit) async {
    _currentActiveFilter = event.active;
    emit(const CitiesLoading());
    final result = await _getCities(
      GetCitiesParams(search: _currentSearch, active: event.active),
    );
    result.fold(
      (failure) => emit(CityError(failure.message)),
      (cities) => emit(CitiesLoaded(
        cities: cities,
        total: cities.length,
        search: _currentSearch,
        activeFilter: event.active,
      )),
    );
  }
}
