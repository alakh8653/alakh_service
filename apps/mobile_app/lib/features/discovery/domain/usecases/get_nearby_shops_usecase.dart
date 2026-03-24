import 'package:dartz/dartz.dart';

import '../../core/failures.dart';
import '../entities/entities.dart';
import '../repositories/discovery_repository.dart';

/// Fetches shops within a given radius of the user's current location.
class GetNearbyShopsUseCase {
  const GetNearbyShopsUseCase(this._repository);

  final DiscoveryRepository _repository;

  Future<Either<Failure, List<Shop>>> call(LocationParams params) =>
      _repository.getNearbyShops(params);
}
