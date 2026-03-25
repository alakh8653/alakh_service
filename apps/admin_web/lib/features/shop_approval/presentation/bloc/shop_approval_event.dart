import 'package:equatable/equatable.dart';
import 'package:admin_web/features/shop_approval/domain/entities/shop_approval_entity.dart';

abstract class ShopApprovalEvent extends Equatable {
  const ShopApprovalEvent();

  @override
  List<Object?> get props => [];
}

class LoadPendingShops extends ShopApprovalEvent {
  final String? search;
  final String? city;

  const LoadPendingShops({this.search, this.city});

  @override
  List<Object?> get props => [search, city];
}

class LoadAllShops extends ShopApprovalEvent {
  final String? search;
  final ShopStatus? status;
  final String? city;

  const LoadAllShops({this.search, this.status, this.city});

  @override
  List<Object?> get props => [search, status, city];
}

class LoadShopById extends ShopApprovalEvent {
  final String id;

  const LoadShopById(this.id);

  @override
  List<Object?> get props => [id];
}

class ApproveShopEvent extends ShopApprovalEvent {
  final String id;
  final String? notes;

  const ApproveShopEvent(this.id, {this.notes});

  @override
  List<Object?> get props => [id, notes];
}

class RejectShopEvent extends ShopApprovalEvent {
  final String id;
  final String reason;

  const RejectShopEvent(this.id, this.reason);

  @override
  List<Object?> get props => [id, reason];
}

class SuspendShopEvent extends ShopApprovalEvent {
  final String id;
  final String reason;

  const SuspendShopEvent(this.id, this.reason);

  @override
  List<Object?> get props => [id, reason];
}

class SearchShops extends ShopApprovalEvent {
  final String query;

  const SearchShops(this.query);

  @override
  List<Object?> get props => [query];
}

class FilterByStatus extends ShopApprovalEvent {
  final ShopStatus? status;

  const FilterByStatus(this.status);

  @override
  List<Object?> get props => [status];
}
