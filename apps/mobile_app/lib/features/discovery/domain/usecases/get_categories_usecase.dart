import 'package:dartz/dartz.dart';

import '../../core/failures.dart';
import '../entities/entities.dart';
import '../repositories/discovery_repository.dart';

/// Returns all service categories available in the platform.
class GetCategoriesUseCase {
  const GetCategoriesUseCase(this._repository);

  final DiscoveryRepository _repository;

  Future<Either<Failure, List<Category>>> call() => _repository.getCategories();
}
