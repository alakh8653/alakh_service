import 'package:dartz/dartz.dart';

import '../../core/failures.dart';
import '../entities/entities.dart';
import '../repositories/discovery_repository.dart';

/// Returns a curated list of trending / featured services.
class GetTrendingServicesUseCase {
  const GetTrendingServicesUseCase(this._repository);

  final DiscoveryRepository _repository;

  Future<Either<Failure, List<Service>>> call() =>
      _repository.getTrendingServices();
}
