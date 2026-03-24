import 'package:dartz/dartz.dart';
import '../entities/dispute.dart';
import '../repositories/dispute_repository.dart';

class EscalateDisputeParams {
  final String disputeId;
  final String reason;

  const EscalateDisputeParams({
    required this.disputeId,
    required this.reason,
  });
}

class EscalateDisputeUsecase {
  final DisputeRepository repository;
  const EscalateDisputeUsecase(this.repository);

  Future<Either<String, Dispute>> call(EscalateDisputeParams params) {
    return repository.escalateDispute(
      disputeId: params.disputeId,
      reason: params.reason,
    );
  }
}
