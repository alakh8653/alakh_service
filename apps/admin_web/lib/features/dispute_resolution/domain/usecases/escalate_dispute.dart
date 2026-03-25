import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:admin_web/core/core.dart';
import 'package:admin_web/features/dispute_resolution/domain/entities/dispute_entity.dart';
import 'package:admin_web/features/dispute_resolution/domain/repositories/dispute_repository.dart';

class EscalateDisputeParams extends Equatable {
  final String id;
  final String reason;

  const EscalateDisputeParams({required this.id, required this.reason});

  @override
  List<Object?> get props => [id, reason];
}

class EscalateDispute extends UseCase<DisputeEntity, EscalateDisputeParams> {
  final DisputeRepository _repository;

  EscalateDispute(this._repository);

  @override
  Future<Either<Failure, DisputeEntity>> call(EscalateDisputeParams params) {
    return _repository.escalateDispute(params.id, params.reason);
  }
}
