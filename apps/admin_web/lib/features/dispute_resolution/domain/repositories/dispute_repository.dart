import 'package:dartz/dartz.dart';
import 'package:admin_web/core/core.dart';
import 'package:admin_web/features/dispute_resolution/domain/entities/dispute_entity.dart';

abstract class DisputeRepository {
  Future<Either<Failure, List<DisputeEntity>>> getDisputes({
    DisputeStatus? status,
    DisputePriority? priority,
    String? search,
  });

  Future<Either<Failure, DisputeEntity>> getDisputeById(String id);

  Future<Either<Failure, DisputeEntity>> resolveDispute(
    String id,
    String resolution,
  );

  Future<Either<Failure, DisputeEntity>> updateStatus(
    String id,
    DisputeStatus status, {
    String? notes,
  });

  Future<Either<Failure, DisputeEntity>> escalateDispute(
    String id,
    String reason,
  );

  Future<Either<Failure, DisputeEntity>> assignDispute(
    String id,
    String adminId,
  );
}
