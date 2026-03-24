import 'package:dartz/dartz.dart';
import '../repositories/dispute_repository.dart';

class CancelDisputeUsecase {
  final DisputeRepository repository;
  const CancelDisputeUsecase(this.repository);

  Future<Either<String, bool>> call(String disputeId) {
    return repository.cancelDispute(disputeId);
  }
}
