import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:admin_web/core/core.dart';
import 'package:admin_web/features/shop_approval/domain/entities/shop_approval_entity.dart';
import 'package:admin_web/features/shop_approval/domain/repositories/shop_approval_repository.dart';

class GetPendingShopsParams extends Equatable {
  final String? search;
  final String? city;

  const GetPendingShopsParams({this.search, this.city});

  @override
  List<Object?> get props => [search, city];
}

class GetPendingShops extends UseCase<List<ShopApprovalEntity>, GetPendingShopsParams> {
  final ShopApprovalRepository _repository;

  GetPendingShops(this._repository);

  @override
  Future<Either<Failure, List<ShopApprovalEntity>>> call(
      GetPendingShopsParams params) {
    return _repository.getPendingShops(search: params.search, city: params.city);
  }
}
