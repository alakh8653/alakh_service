import 'package:dartz/dartz.dart';
import 'package:admin_web/core/core.dart';
import 'package:admin_web/features/city_management/domain/entities/city_entity.dart';
import 'package:admin_web/features/city_management/domain/repositories/city_repository.dart';

class CreateCity extends UseCase<CityEntity, CreateCityParams> {
  final CityRepository _repository;

  CreateCity(this._repository);

  @override
  Future<Either<Failure, CityEntity>> call(CreateCityParams params) {
    return _repository.createCity(params);
  }
}
