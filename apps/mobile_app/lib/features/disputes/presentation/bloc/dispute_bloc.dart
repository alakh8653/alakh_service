import 'package:flutter_bloc/flutter_bloc.dart';
import 'dispute_event.dart';
import 'dispute_state.dart';
import '../../domain/usecases/create_dispute_usecase.dart';
import '../../domain/usecases/get_dispute_details_usecase.dart';
import '../../domain/usecases/get_my_disputes_usecase.dart';
import '../../domain/usecases/submit_evidence_usecase.dart';
import '../../domain/usecases/respond_to_dispute_usecase.dart';
import '../../domain/usecases/escalate_dispute_usecase.dart';
import '../../domain/usecases/cancel_dispute_usecase.dart';
import '../../domain/usecases/accept_resolution_usecase.dart';

class DisputeBloc extends Bloc<DisputeEvent, DisputeState> {
  final CreateDisputeUsecase createDisputeUsecase;
  final GetDisputeDetailsUsecase getDisputeDetailsUsecase;
  final GetMyDisputesUsecase getMyDisputesUsecase;
  final SubmitEvidenceUsecase submitEvidenceUsecase;
  final RespondToDisputeUsecase respondToDisputeUsecase;
  final EscalateDisputeUsecase escalateDisputeUsecase;
  final CancelDisputeUsecase cancelDisputeUsecase;
  final AcceptResolutionUsecase acceptResolutionUsecase;

  DisputeBloc({
    required this.createDisputeUsecase,
    required this.getDisputeDetailsUsecase,
    required this.getMyDisputesUsecase,
    required this.submitEvidenceUsecase,
    required this.respondToDisputeUsecase,
    required this.escalateDisputeUsecase,
    required this.cancelDisputeUsecase,
    required this.acceptResolutionUsecase,
  }) : super(const DisputeInitial()) {
    on<CreateDisputeEvent>(_onCreateDispute);
    on<LoadDisputesEvent>(_onLoadDisputes);
    on<LoadDisputeDetailsEvent>(_onLoadDisputeDetails);
    on<SubmitEvidenceEvent>(_onSubmitEvidence);
    on<RespondToDisputeEvent>(_onRespondToDispute);
    on<EscalateDisputeEvent>(_onEscalateDispute);
    on<CancelDisputeEvent>(_onCancelDispute);
    on<AcceptResolutionEvent>(_onAcceptResolution);
  }

  Future<void> _onCreateDispute(
      CreateDisputeEvent event, Emitter<DisputeState> emit) async {
    emit(const DisputeLoading());
    final result = await createDisputeUsecase(CreateDisputeParams(
      bookingId: event.bookingId,
      type: event.type,
      reason: event.reason,
      description: event.description,
    ));
    result.fold(
      (error) => emit(DisputeError(error)),
      (dispute) => emit(DisputeCreated(dispute)),
    );
  }

  Future<void> _onLoadDisputes(
      LoadDisputesEvent event, Emitter<DisputeState> emit) async {
    emit(const DisputeLoading());
    final result = await getMyDisputesUsecase(activeOnly: event.activeOnly);
    result.fold(
      (error) => emit(DisputeError(error)),
      (disputes) => emit(DisputesLoaded(disputes)),
    );
  }

  Future<void> _onLoadDisputeDetails(
      LoadDisputeDetailsEvent event, Emitter<DisputeState> emit) async {
    emit(const DisputeLoading());
    final result = await getDisputeDetailsUsecase(event.disputeId);
    result.fold(
      (error) => emit(DisputeError(error)),
      (dispute) => emit(DisputeDetailLoaded(dispute)),
    );
  }

  Future<void> _onSubmitEvidence(
      SubmitEvidenceEvent event, Emitter<DisputeState> emit) async {
    emit(const DisputeLoading());
    final result = await submitEvidenceUsecase(SubmitEvidenceParams(
      disputeId: event.disputeId,
      evidenceType: event.evidenceType,
      url: event.url,
      description: event.description,
    ));
    result.fold(
      (error) => emit(DisputeError(error)),
      (evidence) => emit(EvidenceSubmitted(evidence)),
    );
  }

  Future<void> _onRespondToDispute(
      RespondToDisputeEvent event, Emitter<DisputeState> emit) async {
    emit(const DisputeLoading());
    final result = await respondToDisputeUsecase(RespondToDisputeParams(
      disputeId: event.disputeId,
      content: event.content,
    ));
    result.fold(
      (error) => emit(DisputeError(error)),
      (_) => emit(const DisputeInitial()),
    );
  }

  Future<void> _onEscalateDispute(
      EscalateDisputeEvent event, Emitter<DisputeState> emit) async {
    emit(const DisputeLoading());
    final result = await escalateDisputeUsecase(EscalateDisputeParams(
      disputeId: event.disputeId,
      reason: event.reason,
    ));
    result.fold(
      (error) => emit(DisputeError(error)),
      (dispute) => emit(DisputeEscalated(dispute)),
    );
  }

  Future<void> _onCancelDispute(
      CancelDisputeEvent event, Emitter<DisputeState> emit) async {
    emit(const DisputeLoading());
    final result = await cancelDisputeUsecase(event.disputeId);
    result.fold(
      (error) => emit(DisputeError(error)),
      (_) => emit(const DisputeInitial()),
    );
  }

  Future<void> _onAcceptResolution(
      AcceptResolutionEvent event, Emitter<DisputeState> emit) async {
    emit(const DisputeLoading());
    final result = await acceptResolutionUsecase(event.disputeId);
    result.fold(
      (error) => emit(DisputeError(error)),
      (dispute) => emit(DisputeResolved(dispute)),
    );
  }
}
