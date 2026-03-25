import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:admin_web/core/core.dart';
import 'package:admin_web/features/city_management/domain/entities/city_entity.dart';
import 'package:admin_web/features/city_management/domain/repositories/city_repository.dart';

class GetCitiesParams extends Equatable {
  final String? search;
  final bool? active;

  const GetCitiesParams({this.search, this.active});

  @override
  List<Object?> get props => [search, active];
}

class GetCities extends UseCase<List<CityEntity>, GetCitiesParams> {
  final CityRepository _repository;

  GetCities(this._repository);

  @override
  Future<Either<Failure, List<CityEntity>>> call(GetCitiesParams params) {
    return _repository.getCities(search: params.search, active: params.active);
  }
}
