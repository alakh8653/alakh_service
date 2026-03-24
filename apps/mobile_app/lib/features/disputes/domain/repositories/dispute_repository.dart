import 'package:dartz/dartz.dart';
import '../entities/dispute.dart';
import '../entities/dispute_type.dart';
import '../entities/dispute_evidence.dart';

abstract class DisputeRepository {
  Future<Either<String, Dispute>> createDispute({
    required String bookingId,
    required DisputeType type,
    required String reason,
    required String description,
  });

  Future<Either<String, Dispute>> getDisputeDetails(String disputeId);

  Future<Either<String, List<Dispute>>> getMyDisputes({bool? activeOnly});

  Future<Either<String, DisputeEvidence>> submitEvidence({
    required String disputeId,
    required EvidenceType evidenceType,
    required String url,
    required String description,
  });

  Future<Either<String, DisputeMessage>> respondToDispute({
    required String disputeId,
    required String content,
  });

  Future<Either<String, Dispute>> escalateDispute({
    required String disputeId,
    required String reason,
  });

  Future<Either<String, bool>> cancelDispute(String disputeId);

  Future<Either<String, Dispute>> acceptResolution(String disputeId);
}
