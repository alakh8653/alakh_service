import 'package:dartz/dartz.dart';
import '../entities/dispute.dart';
import '../repositories/dispute_repository.dart';

class AcceptResolutionUsecase {
  final DisputeRepository repository;
  const AcceptResolutionUsecase(this.repository);

  Future<Either<String, Dispute>> call(String disputeId) {
    return repository.acceptResolution(disputeId);
  }
}
