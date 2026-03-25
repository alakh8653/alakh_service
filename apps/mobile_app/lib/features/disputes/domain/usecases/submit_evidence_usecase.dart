import 'package:dartz/dartz.dart';
import '../entities/dispute_evidence.dart';
import '../repositories/dispute_repository.dart';

class SubmitEvidenceParams {
  final String disputeId;
  final EvidenceType evidenceType;
  final String url;
  final String description;

  const SubmitEvidenceParams({
    required this.disputeId,
    required this.evidenceType,
    required this.url,
    required this.description,
  });
}

class SubmitEvidenceUsecase {
  final DisputeRepository repository;
  const SubmitEvidenceUsecase(this.repository);

  Future<Either<String, DisputeEvidence>> call(SubmitEvidenceParams params) {
    return repository.submitEvidence(
      disputeId: params.disputeId,
      evidenceType: params.evidenceType,
      url: params.url,
      description: params.description,
    );
  }
}
