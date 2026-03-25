import 'package:dartz/dartz.dart';
import 'package:admin_web/core/core.dart';
import 'package:admin_web/features/city_management/domain/repositories/city_repository.dart';
import 'package:admin_web/features/city_management/domain/usecases/get_city_by_id.dart';

class DeleteCity extends UseCase<Unit, CityIdParams> {
  final CityRepository _repository;

  DeleteCity(this._repository);

  @override
  Future<Either<Failure, Unit>> call(CityIdParams params) {
    return _repository.deleteCity(params.id);
  }
}
