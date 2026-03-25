import 'package:equatable/equatable.dart';
import '../../domain/entities/dispute_type.dart';
import '../../domain/entities/dispute_evidence.dart';

abstract class DisputeEvent extends Equatable {
  const DisputeEvent();
  @override
  List<Object?> get props => [];
}

class CreateDisputeEvent extends DisputeEvent {
  final String bookingId;
  final DisputeType type;
  final String reason;
  final String description;

  const CreateDisputeEvent({
    required this.bookingId,
    required this.type,
    required this.reason,
    required this.description,
  });

  @override
  List<Object?> get props => [bookingId, type, reason, description];
}

class LoadDisputesEvent extends DisputeEvent {
  final bool? activeOnly;
  const LoadDisputesEvent({this.activeOnly});
  @override
  List<Object?> get props => [activeOnly];
}

class LoadDisputeDetailsEvent extends DisputeEvent {
  final String disputeId;
  const LoadDisputeDetailsEvent(this.disputeId);
  @override
  List<Object?> get props => [disputeId];
}

class SubmitEvidenceEvent extends DisputeEvent {
  final String disputeId;
  final EvidenceType evidenceType;
  final String url;
  final String description;

  const SubmitEvidenceEvent({
    required this.disputeId,
    required this.evidenceType,
    required this.url,
    required this.description,
  });

  @override
  List<Object?> get props => [disputeId, evidenceType, url, description];
}

class RespondToDisputeEvent extends DisputeEvent {
  final String disputeId;
  final String content;
  const RespondToDisputeEvent({required this.disputeId, required this.content});
  @override
  List<Object?> get props => [disputeId, content];
}

class EscalateDisputeEvent extends DisputeEvent {
  final String disputeId;
  final String reason;
  const EscalateDisputeEvent({required this.disputeId, required this.reason});
  @override
  List<Object?> get props => [disputeId, reason];
}

class CancelDisputeEvent extends DisputeEvent {
  final String disputeId;
  const CancelDisputeEvent(this.disputeId);
  @override
  List<Object?> get props => [disputeId];
}

class AcceptResolutionEvent extends DisputeEvent {
  final String disputeId;
  const AcceptResolutionEvent(this.disputeId);
  @override
  List<Object?> get props => [disputeId];
}
