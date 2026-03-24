import 'package:dartz/dartz.dart';

import '../../core/failures.dart';
import '../entities/entities.dart';
import '../repositories/discovery_repository.dart';

/// Returns all shops saved as favourites by the current user.
class GetFavoritesUseCase {
  const GetFavoritesUseCase(this._repository);

  final DiscoveryRepository _repository;

  Future<Either<Failure, List<Shop>>> call() => _repository.getFavorites();
}
