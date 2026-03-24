import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:admin_web/core/core.dart';
import 'package:admin_web/features/city_management/domain/entities/city_entity.dart';
import 'package:admin_web/features/city_management/domain/repositories/city_repository.dart';

class UpdateCityUseCaseParams extends Equatable {
  final String id;
  final UpdateCityParams params;

  const UpdateCityUseCaseParams({required this.id, required this.params});

  @override
  List<Object?> get props => [id, params];
}

class UpdateCity extends UseCase<CityEntity, UpdateCityUseCaseParams> {
  final CityRepository _repository;

  UpdateCity(this._repository);

  @override
  Future<Either<Failure, CityEntity>> call(UpdateCityUseCaseParams params) {
    return _repository.updateCity(params.id, params.params);
  }
}
