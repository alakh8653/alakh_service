import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:admin_web/core/core.dart';
import 'package:admin_web/features/shop_approval/domain/entities/shop_approval_entity.dart';
import 'package:admin_web/features/shop_approval/domain/repositories/shop_approval_repository.dart';

class RejectShopParams extends Equatable {
  final String id;
  final String reason;

  const RejectShopParams({required this.id, required this.reason});

  @override
  List<Object?> get props => [id, reason];
}

class RejectShop extends UseCase<ShopApprovalEntity, RejectShopParams> {
  final ShopApprovalRepository _repository;

  RejectShop(this._repository);

  @override
  Future<Either<Failure, ShopApprovalEntity>> call(RejectShopParams params) {
    return _repository.rejectShop(params.id, params.reason);
  }
}
