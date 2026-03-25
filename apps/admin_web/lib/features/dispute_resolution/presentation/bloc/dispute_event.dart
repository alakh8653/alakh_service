import 'package:equatable/equatable.dart';
import 'package:admin_web/features/dispute_resolution/domain/entities/dispute_entity.dart';

abstract class DisputeEvent extends Equatable {
  const DisputeEvent();

  @override
  List<Object?> get props => [];
}

class LoadDisputes extends DisputeEvent {
  final DisputeStatus? status;
  final DisputePriority? priority;
  final String? search;

  const LoadDisputes({this.status, this.priority, this.search});

  @override
  List<Object?> get props => [status, priority, search];
}

class LoadDisputeById extends DisputeEvent {
  final String id;

  const LoadDisputeById(this.id);

  @override
  List<Object?> get props => [id];
}

class ResolveDisputeEvent extends DisputeEvent {
  final String id;
  final String resolution;

  const ResolveDisputeEvent(this.id, this.resolution);

  @override
  List<Object?> get props => [id, resolution];
}

class UpdateDisputeStatusEvent extends DisputeEvent {
  final String id;
  final DisputeStatus status;
  final String? notes;

  const UpdateDisputeStatusEvent(this.id, this.status, {this.notes});

  @override
  List<Object?> get props => [id, status, notes];
}

class EscalateDisputeEvent extends DisputeEvent {
  final String id;
  final String reason;

  const EscalateDisputeEvent(this.id, this.reason);

  @override
  List<Object?> get props => [id, reason];
}

class FilterDisputes extends DisputeEvent {
  final DisputeStatus? status;
  final DisputePriority? priority;
  final String? search;

  const FilterDisputes({this.status, this.priority, this.search});

  @override
  List<Object?> get props => [status, priority, search];
}

class AssignDisputeEvent extends DisputeEvent {
  final String id;
  final String adminId;

  const AssignDisputeEvent(this.id, this.adminId);

  @override
  List<Object?> get props => [id, adminId];
}
