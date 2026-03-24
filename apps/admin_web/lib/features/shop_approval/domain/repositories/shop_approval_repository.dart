import 'package:dartz/dartz.dart';
import 'package:admin_web/core/core.dart';
import 'package:admin_web/features/shop_approval/domain/entities/shop_approval_entity.dart';

abstract class ShopApprovalRepository {
  Future<Either<Failure, List<ShopApprovalEntity>>> getPendingShops({
    String? search,
    String? city,
  });

  Future<Either<Failure, List<ShopApprovalEntity>>> getAllShops({
    String? search,
    ShopStatus? status,
    String? city,
  });

  Future<Either<Failure, ShopApprovalEntity>> getShopById(String id);

  Future<Either<Failure, ShopApprovalEntity>> approveShop(
    String id, {
    String? notes,
  });

  Future<Either<Failure, ShopApprovalEntity>> rejectShop(
    String id,
    String reason,
  );

  Future<Either<Failure, ShopApprovalEntity>> suspendShop(
    String id,
    String reason,
  );
}
