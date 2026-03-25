import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:admin_web/core/core.dart';
import 'package:admin_web/features/city_management/domain/entities/city_entity.dart';
import 'package:admin_web/features/city_management/domain/repositories/city_repository.dart';

class CityIdParams extends Equatable {
  final String id;

  const CityIdParams(this.id);

  @override
  List<Object?> get props => [id];
}

class GetCityById extends UseCase<CityEntity, CityIdParams> {
  final CityRepository _repository;

  GetCityById(this._repository);

  @override
  Future<Either<Failure, CityEntity>> call(CityIdParams params) {
    return _repository.getCityById(params.id);
  }
}
