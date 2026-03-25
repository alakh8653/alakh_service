import 'package:dartz/dartz.dart';
import 'package:admin_web/core/core.dart';
import 'package:admin_web/features/shop_approval/data/datasources/shop_approval_remote_datasource.dart';
import 'package:admin_web/features/shop_approval/domain/entities/shop_approval_entity.dart';
import 'package:admin_web/features/shop_approval/domain/repositories/shop_approval_repository.dart';

class ShopApprovalRepositoryImpl implements ShopApprovalRepository {
  final ShopApprovalRemoteDatasource _datasource;

  ShopApprovalRepositoryImpl(this._datasource);

  @override
  Future<Either<Failure, List<ShopApprovalEntity>>> getPendingShops({
    String? search,
    String? city,
  }) async {
    try {
      final params = <String, dynamic>{};
      if (search != null && search.isNotEmpty) params['search'] = search;
      if (city != null && city.isNotEmpty) params['city'] = city;
      final models = await _datasource.getPendingShops(
          params: params.isEmpty ? null : params);
      return Right(models.map((m) => m.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<ShopApprovalEntity>>> getAllShops({
    String? search,
    ShopStatus? status,
    String? city,
  }) async {
    try {
      final params = <String, dynamic>{};
      if (search != null && search.isNotEmpty) params['search'] = search;
      if (status != null) params['status'] = status.name;
      if (city != null && city.isNotEmpty) params['city'] = city;
      final models = await _datasource.getAllShops(
          params: params.isEmpty ? null : params);
      return Right(models.map((m) => m.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, ShopApprovalEntity>> getShopById(String id) async {
    try {
      final model = await _datasource.getShopById(id);
      return Right(model.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, ShopApprovalEntity>> approveShop(
    String id, {
    String? notes,
  }) async {
    try {
      final model = await _datasource.approveShop(id, notes: notes);
      return Right(model.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, ShopApprovalEntity>> rejectShop(
    String id,
    String reason,
  ) async {
    try {
      final model = await _datasource.rejectShop(id, reason);
      return Right(model.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, ShopApprovalEntity>> suspendShop(
    String id,
    String reason,
  ) async {
    try {
      final model = await _datasource.suspendShop(id, reason);
      return Right(model.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    }
  }
}
