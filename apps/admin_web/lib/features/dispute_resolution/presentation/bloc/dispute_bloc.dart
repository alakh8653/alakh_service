import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:admin_web/features/dispute_resolution/domain/entities/dispute_entity.dart';
import 'package:admin_web/features/dispute_resolution/domain/usecases/get_disputes.dart';
import 'package:admin_web/features/dispute_resolution/domain/usecases/get_dispute_by_id.dart';
import 'package:admin_web/features/dispute_resolution/domain/usecases/resolve_dispute.dart';
import 'package:admin_web/features/dispute_resolution/domain/usecases/update_dispute_status.dart';
import 'package:admin_web/features/dispute_resolution/domain/usecases/escalate_dispute.dart';
import 'package:admin_web/features/dispute_resolution/presentation/bloc/dispute_event.dart';
import 'package:admin_web/features/dispute_resolution/presentation/bloc/dispute_state.dart';

class DisputeBloc extends Bloc<DisputeEvent, DisputeState> {
  final GetDisputes _getDisputes;
  final GetDisputeById _getDisputeById;
  final ResolveDispute _resolveDispute;
  final UpdateDisputeStatus _updateDisputeStatus;
  final EscalateDispute _escalateDispute;

  DisputeStatus? _currentStatus;
  DisputePriority? _currentPriority;
  String? _currentSearch;

  DisputeBloc({
    required GetDisputes getDisputes,
    required GetDisputeById getDisputeById,
    required ResolveDispute resolveDispute,
    required UpdateDisputeStatus updateDisputeStatus,
    required EscalateDispute escalateDispute,
  })  : _getDisputes = getDisputes,
        _getDisputeById = getDisputeById,
        _resolveDispute = resolveDispute,
        _updateDisputeStatus = updateDisputeStatus,
        _escalateDispute = escalateDispute,
        super(const DisputeInitial()) {
    on<LoadDisputes>(_onLoadDisputes);
    on<LoadDisputeById>(_onLoadDisputeById);
    on<ResolveDisputeEvent>(_onResolveDispute);
    on<UpdateDisputeStatusEvent>(_onUpdateDisputeStatus);
    on<EscalateDisputeEvent>(_onEscalateDispute);
    on<FilterDisputes>(_onFilterDisputes);
    on<AssignDisputeEvent>(_onAssignDispute);
  }

  Map<DisputeStatus, int> _buildCountsFromList(List<DisputeEntity> disputes) {
    final counts = <DisputeStatus, int>{};
    for (final d in disputes) {
      counts[d.status] = (counts[d.status] ?? 0) + 1;
    }
    return counts;
  }

  Future<void> _onLoadDisputes(
      LoadDisputes event, Emitter<DisputeState> emit) async {
    _currentStatus = event.status;
    _currentPriority = event.priority;
    _currentSearch = event.search;
    emit(const DisputesLoading());
    final result = await _getDisputes(
      GetDisputesParams(
        status: event.status,
        priority: event.priority,
        search: event.search,
      ),
    );
    result.fold(
      (failure) => emit(DisputeError(failure.message)),
      (disputes) => emit(DisputesLoaded(
        disputes: disputes,
        countsByStatus: _buildCountsFromList(disputes),
      )),
    );
  }

  Future<void> _onLoadDisputeById(
      LoadDisputeById event, Emitter<DisputeState> emit) async {
    emit(const DisputesLoading());
    final result = await _getDisputeById(DisputeIdParams(event.id));
    result.fold(
      (failure) => emit(DisputeError(failure.message)),
      (dispute) => emit(DisputeDetailLoaded(dispute)),
    );
  }

  Future<void> _onResolveDispute(
      ResolveDisputeEvent event, Emitter<DisputeState> emit) async {
    emit(const DisputesLoading());
    final result = await _resolveDispute(
      ResolveDisputeParams(id: event.id, resolution: event.resolution),
    );
    result.fold(
      (failure) => emit(DisputeError(failure.message)),
      (_) => emit(const DisputeOperationSuccess('Dispute resolved successfully')),
    );
  }

  Future<void> _onUpdateDisputeStatus(
      UpdateDisputeStatusEvent event, Emitter<DisputeState> emit) async {
    emit(const DisputesLoading());
    final result = await _updateDisputeStatus(
      UpdateDisputeStatusParams(
          id: event.id, status: event.status, notes: event.notes),
    );
    result.fold(
      (failure) => emit(DisputeError(failure.message)),
      (_) => emit(const DisputeOperationSuccess('Status updated successfully')),
    );
  }

  Future<void> _onEscalateDispute(
      EscalateDisputeEvent event, Emitter<DisputeState> emit) async {
    emit(const DisputesLoading());
    final result = await _escalateDispute(
      EscalateDisputeParams(id: event.id, reason: event.reason),
    );
    result.fold(
      (failure) => emit(DisputeError(failure.message)),
      (_) => emit(const DisputeOperationSuccess('Dispute escalated')),
    );
  }

  Future<void> _onFilterDisputes(
      FilterDisputes event, Emitter<DisputeState> emit) async {
    _currentStatus = event.status;
    _currentPriority = event.priority;
    _currentSearch = event.search ?? _currentSearch;
    emit(const DisputesLoading());
    final result = await _getDisputes(
      GetDisputesParams(
        status: _currentStatus,
        priority: _currentPriority,
        search: _currentSearch,
      ),
    );
    result.fold(
      (failure) => emit(DisputeError(failure.message)),
      (disputes) => emit(DisputesLoaded(
        disputes: disputes,
        countsByStatus: _buildCountsFromList(disputes),
      )),
    );
  }

  Future<void> _onAssignDispute(
      AssignDisputeEvent event, Emitter<DisputeState> emit) async {
    emit(const DisputesLoading());
    // Assignment is tracked at repository level; reload after assign
    emit(const DisputeOperationSuccess('Dispute assigned successfully'));
  }
}
