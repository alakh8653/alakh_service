import 'package:equatable/equatable.dart';
import 'package:admin_web/features/shop_approval/domain/entities/shop_approval_entity.dart';

abstract class ShopApprovalState extends Equatable {
  const ShopApprovalState();

  @override
  List<Object?> get props => [];
}

class ShopApprovalInitial extends ShopApprovalState {
  const ShopApprovalInitial();
}

class ShopsLoading extends ShopApprovalState {
  const ShopsLoading();
}

class PendingShopsLoaded extends ShopApprovalState {
  final List<ShopApprovalEntity> shops;

  const PendingShopsLoaded(this.shops);

  @override
  List<Object?> get props => [shops];
}

class AllShopsLoaded extends ShopApprovalState {
  final List<ShopApprovalEntity> shops;
  final int total;

  const AllShopsLoaded(this.shops, this.total);

  @override
  List<Object?> get props => [shops, total];
}

class ShopDetailLoaded extends ShopApprovalState {
  final ShopApprovalEntity shop;

  const ShopDetailLoaded(this.shop);

  @override
  List<Object?> get props => [shop];
}

class ShopOperationSuccess extends ShopApprovalState {
  final String message;
  final ShopApprovalEntity shop;

  const ShopOperationSuccess(this.message, this.shop);

  @override
  List<Object?> get props => [message, shop];
}

class ShopApprovalError extends ShopApprovalState {
  final String message;

  const ShopApprovalError(this.message);

  @override
  List<Object?> get props => [message];
}
