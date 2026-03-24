import 'package:dartz/dartz.dart';
import 'package:admin_web/core/core.dart';
import 'package:admin_web/features/dispute_resolution/data/datasources/dispute_remote_datasource.dart';
import 'package:admin_web/features/dispute_resolution/domain/entities/dispute_entity.dart';
import 'package:admin_web/features/dispute_resolution/domain/repositories/dispute_repository.dart';

class DisputeRepositoryImpl implements DisputeRepository {
  final DisputeRemoteDatasource _datasource;

  DisputeRepositoryImpl(this._datasource);

  @override
  Future<Either<Failure, List<DisputeEntity>>> getDisputes({
    DisputeStatus? status,
    DisputePriority? priority,
    String? search,
  }) async {
    try {
      final params = <String, dynamic>{};
      if (status != null) params['status'] = status.name;
      if (priority != null) params['priority'] = priority.name;
      if (search != null && search.isNotEmpty) params['search'] = search;
      final models = await _datasource.getDisputes(
          params: params.isEmpty ? null : params);
      return Right(models.map((m) => m.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, DisputeEntity>> getDisputeById(String id) async {
    try {
      final model = await _datasource.getDisputeById(id);
      return Right(model.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, DisputeEntity>> resolveDispute(
    String id,
    String resolution,
  ) async {
    try {
      final model = await _datasource.resolveDispute(id, resolution);
      return Right(model.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, DisputeEntity>> updateStatus(
    String id,
    DisputeStatus status, {
    String? notes,
  }) async {
    try {
      final model =
          await _datasource.updateDisputeStatus(id, status.name, notes);
      return Right(model.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, DisputeEntity>> escalateDispute(
    String id,
    String reason,
  ) async {
    try {
      final model = await _datasource.escalateDispute(id, reason);
      return Right(model.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, DisputeEntity>> assignDispute(
    String id,
    String adminId,
  ) async {
    try {
      final model = await _datasource.assignDispute(id, adminId);
      return Right(model.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    }
  }
}
