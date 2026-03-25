import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:admin_web/core/core.dart';
import 'package:admin_web/features/city_management/domain/entities/city_entity.dart';
import 'package:admin_web/features/city_management/domain/repositories/city_repository.dart';

class ToggleCityStatusParams extends Equatable {
  final String id;
  final bool active;

  const ToggleCityStatusParams({required this.id, required this.active});

  @override
  List<Object?> get props => [id, active];
}

class ToggleCityStatus extends UseCase<CityEntity, ToggleCityStatusParams> {
  final CityRepository _repository;

  ToggleCityStatus(this._repository);

  @override
  Future<Either<Failure, CityEntity>> call(ToggleCityStatusParams params) {
    return _repository.toggleCityStatus(params.id, params.active);
  }
}
