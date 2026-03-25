import 'package:dartz/dartz.dart';

import '../../core/failures.dart';
import '../repositories/discovery_repository.dart';

/// Retrieves the user's recent search history.
class GetRecentSearchesUseCase {
  const GetRecentSearchesUseCase(this._repository);

  final DiscoveryRepository _repository;

  Future<Either<Failure, List<String>>> call() =>
      _repository.getRecentSearches();
}
