import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../entities/dispatch_job.dart';
import '../repositories/dispatch_repository.dart';

/// Retrieves a paginated history of completed and cancelled dispatch jobs.
class GetDispatchHistoryUseCase {
  final DispatchRepository repository;

  const GetDispatchHistoryUseCase(this.repository);

  Future<Either<Failure, List<DispatchJob>>> call(GetDispatchHistoryParams params) =>
      repository.getDispatchHistory(page: params.page);
}

/// Parameters required by [GetDispatchHistoryUseCase].
class GetDispatchHistoryParams extends Equatable {
  final int page;

  const GetDispatchHistoryParams({this.page = 1});

  @override
  List<Object?> get props => [page];
}
