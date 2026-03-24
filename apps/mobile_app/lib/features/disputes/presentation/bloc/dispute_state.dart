import 'package:equatable/equatable.dart';
import '../../domain/entities/dispute.dart';
import '../../domain/entities/dispute_evidence.dart';

abstract class DisputeState extends Equatable {
  const DisputeState();
  @override
  List<Object?> get props => [];
}

class DisputeInitial extends DisputeState {
  const DisputeInitial();
}

class DisputeLoading extends DisputeState {
  const DisputeLoading();
}

class DisputeCreated extends DisputeState {
  final Dispute dispute;
  const DisputeCreated(this.dispute);
  @override
  List<Object?> get props => [dispute];
}

class DisputesLoaded extends DisputeState {
  final List<Dispute> disputes;
  const DisputesLoaded(this.disputes);
  @override
  List<Object?> get props => [disputes];
}

class DisputeDetailLoaded extends DisputeState {
  final Dispute dispute;
  const DisputeDetailLoaded(this.dispute);
  @override
  List<Object?> get props => [dispute];
}

class EvidenceSubmitted extends DisputeState {
  final DisputeEvidence evidence;
  const EvidenceSubmitted(this.evidence);
  @override
  List<Object?> get props => [evidence];
}

class DisputeEscalated extends DisputeState {
  final Dispute dispute;
  const DisputeEscalated(this.dispute);
  @override
  List<Object?> get props => [dispute];
}

class DisputeResolved extends DisputeState {
  final Dispute dispute;
  const DisputeResolved(this.dispute);
  @override
  List<Object?> get props => [dispute];
}

class DisputeError extends DisputeState {
  final String message;
  const DisputeError(this.message);
  @override
  List<Object?> get props => [message];
}
