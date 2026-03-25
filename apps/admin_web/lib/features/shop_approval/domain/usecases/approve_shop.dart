import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:admin_web/core/core.dart';
import 'package:admin_web/features/shop_approval/domain/entities/shop_approval_entity.dart';
import 'package:admin_web/features/shop_approval/domain/repositories/shop_approval_repository.dart';

class ApproveShopParams extends Equatable {
  final String id;
  final String? notes;

  const ApproveShopParams({required this.id, this.notes});

  @override
  List<Object?> get props => [id, notes];
}

class ApproveShop extends UseCase<ShopApprovalEntity, ApproveShopParams> {
  final ShopApprovalRepository _repository;

  ApproveShop(this._repository);

  @override
  Future<Either<Failure, ShopApprovalEntity>> call(ApproveShopParams params) {
    return _repository.approveShop(params.id, notes: params.notes);
  }
}
