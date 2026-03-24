import 'package:dartz/dartz.dart';
import '../entities/dispute.dart';
import '../repositories/dispute_repository.dart';

class GetMyDisputesUsecase {
  final DisputeRepository repository;
  const GetMyDisputesUsecase(this.repository);

  Future<Either<String, List<Dispute>>> call({bool? activeOnly}) {
    return repository.getMyDisputes(activeOnly: activeOnly);
  }
}
