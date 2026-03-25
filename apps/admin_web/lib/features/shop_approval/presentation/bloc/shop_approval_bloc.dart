import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:admin_web/features/shop_approval/domain/usecases/get_pending_shops.dart';
import 'package:admin_web/features/shop_approval/domain/usecases/get_all_shops.dart';
import 'package:admin_web/features/shop_approval/domain/usecases/get_shop_by_id.dart';
import 'package:admin_web/features/shop_approval/domain/usecases/approve_shop.dart';
import 'package:admin_web/features/shop_approval/domain/usecases/reject_shop.dart';
import 'package:admin_web/features/shop_approval/domain/entities/shop_approval_entity.dart';
import 'package:admin_web/features/shop_approval/presentation/bloc/shop_approval_event.dart';
import 'package:admin_web/features/shop_approval/presentation/bloc/shop_approval_state.dart';

class ShopApprovalBloc extends Bloc<ShopApprovalEvent, ShopApprovalState> {
  final GetPendingShops _getPendingShops;
  final GetAllShops _getAllShops;
  final GetShopById _getShopById;
  final ApproveShop _approveShop;
  final RejectShop _rejectShop;

  ShopStatus? _currentStatusFilter;
  String? _currentSearch;

  ShopApprovalBloc({
    required GetPendingShops getPendingShops,
    required GetAllShops getAllShops,
    required GetShopById getShopById,
    required ApproveShop approveShop,
    required RejectShop rejectShop,
  })  : _getPendingShops = getPendingShops,
        _getAllShops = getAllShops,
        _getShopById = getShopById,
        _approveShop = approveShop,
        _rejectShop = rejectShop,
        super(const ShopApprovalInitial()) {
    on<LoadPendingShops>(_onLoadPendingShops);
    on<LoadAllShops>(_onLoadAllShops);
    on<LoadShopById>(_onLoadShopById);
    on<ApproveShopEvent>(_onApproveShop);
    on<RejectShopEvent>(_onRejectShop);
    on<SuspendShopEvent>(_onSuspendShop);
    on<SearchShops>(_onSearchShops);
    on<FilterByStatus>(_onFilterByStatus);
  }

  Future<void> _onLoadPendingShops(
      LoadPendingShops event, Emitter<ShopApprovalState> emit) async {
    emit(const ShopsLoading());
    final result = await _getPendingShops(
      GetPendingShopsParams(search: event.search, city: event.city),
    );
    result.fold(
      (failure) => emit(ShopApprovalError(failure.message)),
      (shops) => emit(PendingShopsLoaded(shops)),
    );
  }

  Future<void> _onLoadAllShops(
      LoadAllShops event, Emitter<ShopApprovalState> emit) async {
    _currentStatusFilter = event.status;
    _currentSearch = event.search;
    emit(const ShopsLoading());
    final result = await _getAllShops(
      GetAllShopsParams(
        search: event.search,
        status: event.status,
        city: event.city,
      ),
    );
    result.fold(
      (failure) => emit(ShopApprovalError(failure.message)),
      (shops) => emit(AllShopsLoaded(shops, shops.length)),
    );
  }

  Future<void> _onLoadShopById(
      LoadShopById event, Emitter<ShopApprovalState> emit) async {
    emit(const ShopsLoading());
    final result = await _getShopById(ShopIdParams(event.id));
    result.fold(
      (failure) => emit(ShopApprovalError(failure.message)),
      (shop) => emit(ShopDetailLoaded(shop)),
    );
  }

  Future<void> _onApproveShop(
      ApproveShopEvent event, Emitter<ShopApprovalState> emit) async {
    emit(const ShopsLoading());
    final result = await _approveShop(
      ApproveShopParams(id: event.id, notes: event.notes),
    );
    result.fold(
      (failure) => emit(ShopApprovalError(failure.message)),
      (shop) => emit(ShopOperationSuccess('Shop approved successfully', shop)),
    );
  }

  Future<void> _onRejectShop(
      RejectShopEvent event, Emitter<ShopApprovalState> emit) async {
    emit(const ShopsLoading());
    final result = await _rejectShop(
      RejectShopParams(id: event.id, reason: event.reason),
    );
    result.fold(
      (failure) => emit(ShopApprovalError(failure.message)),
      (shop) => emit(ShopOperationSuccess('Shop rejected', shop)),
    );
  }

  Future<void> _onSuspendShop(
      SuspendShopEvent event, Emitter<ShopApprovalState> emit) async {
    // SuspendShop use case can be added; using RejectShop as fallback pattern
    emit(ShopApprovalError('Suspend use case not implemented'));
  }

  Future<void> _onSearchShops(
      SearchShops event, Emitter<ShopApprovalState> emit) async {
    _currentSearch = event.query.isEmpty ? null : event.query;
    emit(const ShopsLoading());
    final result = await _getAllShops(
      GetAllShopsParams(search: _currentSearch, status: _currentStatusFilter),
    );
    result.fold(
      (failure) => emit(ShopApprovalError(failure.message)),
      (shops) => emit(AllShopsLoaded(shops, shops.length)),
    );
  }

  Future<void> _onFilterByStatus(
      FilterByStatus event, Emitter<ShopApprovalState> emit) async {
    _currentStatusFilter = event.status;
    emit(const ShopsLoading());
    final result = await _getAllShops(
      GetAllShopsParams(search: _currentSearch, status: event.status),
    );
    result.fold(
      (failure) => emit(ShopApprovalError(failure.message)),
      (shops) => emit(AllShopsLoaded(shops, shops.length)),
    );
  }
}
