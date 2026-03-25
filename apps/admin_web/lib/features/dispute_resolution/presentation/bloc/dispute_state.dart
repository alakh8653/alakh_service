import 'package:equatable/equatable.dart';
import 'package:admin_web/features/dispute_resolution/domain/entities/dispute_entity.dart';

abstract class DisputeState extends Equatable {
  const DisputeState();

  @override
  List<Object?> get props => [];
}

class DisputeInitial extends DisputeState {
  const DisputeInitial();
}

class DisputesLoading extends DisputeState {
  const DisputesLoading();
}

class DisputesLoaded extends DisputeState {
  final List<DisputeEntity> disputes;
  final Map<DisputeStatus, int> countsByStatus;

  const DisputesLoaded({
    required this.disputes,
    required this.countsByStatus,
  });

  int get openCount => countsByStatus[DisputeStatus.open] ?? 0;
  int get inProgressCount => countsByStatus[DisputeStatus.inProgress] ?? 0;
  int get escalatedCount => countsByStatus[DisputeStatus.escalated] ?? 0;
  int get resolvedCount => countsByStatus[DisputeStatus.resolved] ?? 0;

  @override
  List<Object?> get props => [disputes, countsByStatus];
}

class DisputeDetailLoaded extends DisputeState {
  final DisputeEntity dispute;

  const DisputeDetailLoaded(this.dispute);

  @override
  List<Object?> get props => [dispute];
}

class DisputeOperationSuccess extends DisputeState {
  final String message;

  const DisputeOperationSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class DisputeError extends DisputeState {
  final String message;

  const DisputeError(this.message);

  @override
  List<Object?> get props => [message];
}
