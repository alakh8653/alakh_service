import 'package:dartz/dartz.dart';

import '../../core/failures.dart';
import '../repositories/discovery_repository.dart';

/// Searches services/shops based on a query and optional filters.
class SearchServicesUseCase {
  const SearchServicesUseCase(this._repository);

  final DiscoveryRepository _repository;

  Future<Either<Failure, SearchResult>> call(SearchParams params) =>
      _repository.searchServices(params);
}
