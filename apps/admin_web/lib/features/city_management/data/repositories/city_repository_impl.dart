import 'package:dartz/dartz.dart';
import 'package:admin_web/core/core.dart';
import 'package:admin_web/features/city_management/data/datasources/city_remote_datasource.dart';
import 'package:admin_web/features/city_management/domain/entities/city_entity.dart';
import 'package:admin_web/features/city_management/domain/repositories/city_repository.dart';

class CityRepositoryImpl implements CityRepository {
  final CityRemoteDatasource _datasource;

  CityRepositoryImpl(this._datasource);

  @override
  Future<Either<Failure, List<CityEntity>>> getCities({
    String? search,
    bool? active,
  }) async {
    try {
      final params = <String, dynamic>{};
      if (search != null && search.isNotEmpty) params['search'] = search;
      if (active != null) params['isActive'] = active;
      final models = await _datasource.getCities(params: params.isEmpty ? null : params);
      return Right(models.map((m) => m.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, CityEntity>> getCityById(String id) async {
    try {
      final model = await _datasource.getCityById(id);
      return Right(model.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, CityEntity>> createCity(CreateCityParams params) async {
    try {
      final model = await _datasource.createCity(params.toJson());
      return Right(model.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, CityEntity>> updateCity(
      String id, UpdateCityParams params) async {
    try {
      final model = await _datasource.updateCity(id, params.toJson());
      return Right(model.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteCity(String id) async {
    try {
      await _datasource.deleteCity(id);
      return const Right(unit);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, CityEntity>> toggleCityStatus(
      String id, bool active) async {
    try {
      final model = await _datasource.toggleCityStatus(id, active);
      return Right(model.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    }
  }
}
