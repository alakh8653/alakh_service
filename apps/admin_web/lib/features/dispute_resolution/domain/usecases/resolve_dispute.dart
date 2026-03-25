import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:admin_web/core/core.dart';
import 'package:admin_web/features/dispute_resolution/domain/entities/dispute_entity.dart';
import 'package:admin_web/features/dispute_resolution/domain/repositories/dispute_repository.dart';

class ResolveDisputeParams extends Equatable {
  final String id;
  final String resolution;

  const ResolveDisputeParams({required this.id, required this.resolution});

  @override
  List<Object?> get props => [id, resolution];
}

class ResolveDispute extends UseCase<DisputeEntity, ResolveDisputeParams> {
  final DisputeRepository _repository;

  ResolveDispute(this._repository);

  @override
  Future<Either<Failure, DisputeEntity>> call(ResolveDisputeParams params) {
    return _repository.resolveDispute(params.id, params.resolution);
  }
}
