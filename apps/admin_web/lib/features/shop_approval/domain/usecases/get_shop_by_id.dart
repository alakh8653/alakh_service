import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:admin_web/core/core.dart';
import 'package:admin_web/features/shop_approval/domain/entities/shop_approval_entity.dart';
import 'package:admin_web/features/shop_approval/domain/repositories/shop_approval_repository.dart';

class ShopIdParams extends Equatable {
  final String id;

  const ShopIdParams(this.id);

  @override
  List<Object?> get props => [id];
}

class GetShopById extends UseCase<ShopApprovalEntity, ShopIdParams> {
  final ShopApprovalRepository _repository;

  GetShopById(this._repository);

  @override
  Future<Either<Failure, ShopApprovalEntity>> call(ShopIdParams params) {
    return _repository.getShopById(params.id);
  }
}
