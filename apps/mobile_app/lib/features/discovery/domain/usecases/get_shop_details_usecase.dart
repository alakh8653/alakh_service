import 'package:dartz/dartz.dart';

import '../../core/failures.dart';
import '../entities/entities.dart';
import '../repositories/discovery_repository.dart';

/// Loads the full profile of a single shop identified by [shopId].
class GetShopDetailsUseCase {
  const GetShopDetailsUseCase(this._repository);

  final DiscoveryRepository _repository;

  Future<Either<Failure, Shop>> call(String shopId) =>
      _repository.getShopDetails(shopId);
}
