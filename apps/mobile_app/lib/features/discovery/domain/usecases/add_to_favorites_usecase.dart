import 'package:dartz/dartz.dart';

import '../../core/failures.dart';
import '../repositories/discovery_repository.dart';

/// Adds a shop to the current user's favourites list.
class AddToFavoritesUseCase {
  const AddToFavoritesUseCase(this._repository);

  final DiscoveryRepository _repository;

  Future<Either<Failure, void>> call(String shopId) =>
      _repository.addToFavorites(shopId);
}
