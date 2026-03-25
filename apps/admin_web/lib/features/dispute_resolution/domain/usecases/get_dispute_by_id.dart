import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:admin_web/core/core.dart';
import 'package:admin_web/features/dispute_resolution/domain/entities/dispute_entity.dart';
import 'package:admin_web/features/dispute_resolution/domain/repositories/dispute_repository.dart';

class DisputeIdParams extends Equatable {
  final String id;

  const DisputeIdParams(this.id);

  @override
  List<Object?> get props => [id];
}

class GetDisputeById extends UseCase<DisputeEntity, DisputeIdParams> {
  final DisputeRepository _repository;

  GetDisputeById(this._repository);

  @override
  Future<Either<Failure, DisputeEntity>> call(DisputeIdParams params) {
    return _repository.getDisputeById(params.id);
  }
}
