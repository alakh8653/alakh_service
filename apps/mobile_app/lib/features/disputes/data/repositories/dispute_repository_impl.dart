import 'package:dartz/dartz.dart';
import '../datasources/dispute_remote_datasource.dart';
import '../datasources/dispute_local_datasource.dart';
import '../../domain/entities/dispute.dart';
import '../../domain/entities/dispute_type.dart';
import '../../domain/entities/dispute_evidence.dart';
import '../../domain/repositories/dispute_repository.dart';

class DisputeRepositoryImpl implements DisputeRepository {
  final DisputeRemoteDataSource remoteDataSource;
  final DisputeLocalDataSource localDataSource;

  const DisputeRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<String, Dispute>> createDispute({
    required String bookingId,
    required DisputeType type,
    required String reason,
    required String description,
  }) async {
    try {
      final dispute = await remoteDataSource.createDispute(
        bookingId: bookingId,
        type: type,
        reason: reason,
        description: description,
      );
      await localDataSource.cacheDisputeDetails(dispute);
      return Right(dispute);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, Dispute>> getDisputeDetails(String disputeId) async {
    try {
      final dispute = await remoteDataSource.getDisputeDetails(disputeId);
      await localDataSource.cacheDisputeDetails(dispute);
      return Right(dispute);
    } catch (e) {
      final cached = await localDataSource.getCachedDisputeDetails(disputeId);
      if (cached != null) return Right(cached);
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, List<Dispute>>> getMyDisputes({bool? activeOnly}) async {
    try {
      final disputes = await remoteDataSource.getMyDisputes(activeOnly: activeOnly);
      await localDataSource.cacheDisputes(disputes);
      return Right(disputes);
    } catch (e) {
      final cached = await localDataSource.getCachedDisputes();
      if (cached.isNotEmpty) return Right(cached);
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, DisputeEvidence>> submitEvidence({
    required String disputeId,
    required EvidenceType evidenceType,
    required String url,
    required String description,
  }) async {
    try {
      final evidence = await remoteDataSource.submitEvidence(
        disputeId: disputeId,
        evidenceType: evidenceType,
        url: url,
        description: description,
      );
      return Right(evidence);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, DisputeMessage>> respondToDispute({
    required String disputeId,
    required String content,
  }) async {
    try {
      final message = await remoteDataSource.respondToDispute(
        disputeId: disputeId,
        content: content,
      );
      return Right(message);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, Dispute>> escalateDispute({
    required String disputeId,
    required String reason,
  }) async {
    try {
      final dispute = await remoteDataSource.escalateDispute(
        disputeId: disputeId,
        reason: reason,
      );
      return Right(dispute);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, bool>> cancelDispute(String disputeId) async {
    try {
      final result = await remoteDataSource.cancelDispute(disputeId);
      return Right(result);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, Dispute>> acceptResolution(String disputeId) async {
    try {
      final dispute = await remoteDataSource.acceptResolution(disputeId);
      return Right(dispute);
    } catch (e) {
      return Left(e.toString());
    }
  }
}
