import 'package:dartz/dartz.dart';
import '../entities/dispute.dart';
import '../repositories/dispute_repository.dart';

class GetDisputeDetailsUsecase {
  final DisputeRepository repository;
  const GetDisputeDetailsUsecase(this.repository);

  Future<Either<String, Dispute>> call(String disputeId) {
    return repository.getDisputeDetails(disputeId);
  }
}
