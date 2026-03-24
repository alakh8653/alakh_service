import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:admin_web/core/core.dart';
import 'package:admin_web/features/dispute_resolution/domain/entities/dispute_entity.dart';
import 'package:admin_web/features/dispute_resolution/domain/repositories/dispute_repository.dart';

class UpdateDisputeStatusParams extends Equatable {
  final String id;
  final DisputeStatus status;
  final String? notes;

  const UpdateDisputeStatusParams({
    required this.id,
    required this.status,
    this.notes,
  });

  @override
  List<Object?> get props => [id, status, notes];
}

class UpdateDisputeStatus
    extends UseCase<DisputeEntity, UpdateDisputeStatusParams> {
  final DisputeRepository _repository;

  UpdateDisputeStatus(this._repository);

  @override
  Future<Either<Failure, DisputeEntity>> call(
      UpdateDisputeStatusParams params) {
    return _repository.updateStatus(params.id, params.status,
        notes: params.notes);
  }
}
