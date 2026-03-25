/// Use case for retrieving the full list of staff members.
///
/// Implements [UseCase]<[List]<[StaffMember]>, [NoParams]>.
library;

import 'package:dartz/dartz.dart';
import 'package:shop_web/core/errors/shop_error_handler.dart';
import 'package:shop_web/features/staff_management/domain/entities/staff_member.dart';
import 'package:shop_web/features/staff_management/domain/repositories/staff_management_repository.dart';

/// Fetches the complete staff roster from the repository.
class GetStaffListUseCase implements UseCase<List<StaffMember>, NoParams> {
  /// Creates the use case with the required [repository].
  const GetStaffListUseCase({required this.repository});

  /// The staff management repository.
  final StaffManagementRepository repository;

  @override
  Future<Either<Failure, List<StaffMember>>> call(NoParams params) {
    return repository.getStaffList();
  }
}
