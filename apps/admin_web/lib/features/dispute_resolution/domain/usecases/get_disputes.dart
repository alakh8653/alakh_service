import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:admin_web/core/core.dart';
import 'package:admin_web/features/dispute_resolution/domain/entities/dispute_entity.dart';
import 'package:admin_web/features/dispute_resolution/domain/repositories/dispute_repository.dart';

class GetDisputesParams extends Equatable {
  final DisputeStatus? status;
  final DisputePriority? priority;
  final String? search;

  const GetDisputesParams({this.status, this.priority, this.search});

  @override
  List<Object?> get props => [status, priority, search];
}

class GetDisputes extends UseCase<List<DisputeEntity>, GetDisputesParams> {
  final DisputeRepository _repository;

  GetDisputes(this._repository);

  @override
  Future<Either<Failure, List<DisputeEntity>>> call(
      GetDisputesParams params) {
    return _repository.getDisputes(
      status: params.status,
      priority: params.priority,
      search: params.search,
    );
  }
}
