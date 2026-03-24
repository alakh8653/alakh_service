import 'package:dartz/dartz.dart';
import '../entities/dispute.dart';
import '../repositories/dispute_repository.dart';

class RespondToDisputeParams {
  final String disputeId;
  final String content;

  const RespondToDisputeParams({
    required this.disputeId,
    required this.content,
  });
}

class RespondToDisputeUsecase {
  final DisputeRepository repository;
  const RespondToDisputeUsecase(this.repository);

  Future<Either<String, DisputeMessage>> call(RespondToDisputeParams params) {
    return repository.respondToDispute(
      disputeId: params.disputeId,
      content: params.content,
    );
  }
}
