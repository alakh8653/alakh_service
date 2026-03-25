import 'package:dartz/dartz.dart';
import '../entities/dispute.dart';
import '../entities/dispute_type.dart';
import '../repositories/dispute_repository.dart';

class CreateDisputeParams {
  final String bookingId;
  final DisputeType type;
  final String reason;
  final String description;

  const CreateDisputeParams({
    required this.bookingId,
    required this.type,
    required this.reason,
    required this.description,
  });
}

class CreateDisputeUsecase {
  final DisputeRepository repository;
  const CreateDisputeUsecase(this.repository);

  Future<Either<String, Dispute>> call(CreateDisputeParams params) {
    return repository.createDispute(
      bookingId: params.bookingId,
      type: params.type,
      reason: params.reason,
      description: params.description,
    );
  }
}
