import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:admin_web/core/core.dart';
import 'package:admin_web/features/shop_approval/domain/entities/shop_approval_entity.dart';
import 'package:admin_web/features/shop_approval/domain/repositories/shop_approval_repository.dart';

class GetAllShopsParams extends Equatable {
  final String? search;
  final ShopStatus? status;
  final String? city;

  const GetAllShopsParams({this.search, this.status, this.city});

  @override
  List<Object?> get props => [search, status, city];
}

class GetAllShops extends UseCase<List<ShopApprovalEntity>, GetAllShopsParams> {
  final ShopApprovalRepository _repository;

  GetAllShops(this._repository);

  @override
  Future<Either<Failure, List<ShopApprovalEntity>>> call(
      GetAllShopsParams params) {
    return _repository.getAllShops(
      search: params.search,
      status: params.status,
      city: params.city,
    );
  }
}
