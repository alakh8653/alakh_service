/// Use case for removing a staff member.
///
/// Implements [UseCase]<void, [RemoveStaffParams]>.
library;

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:shop_web/core/errors/shop_error_handler.dart';
import 'package:shop_web/features/staff_management/domain/repositories/staff_management_repository.dart';

/// Parameters required to remove a staff member.
class RemoveStaffParams extends Equatable {
  /// Creates [RemoveStaffParams] with the [id] of the member to remove.
  const RemoveStaffParams({required this.id});

  /// ID of the staff member to permanently remove.
  final String id;

  @override
  List<Object?> get props => [id];
}

/// Permanently removes a staff member via the repository.
class RemoveStaffMemberUseCase implements UseCase<void, RemoveStaffParams> {
  /// Creates the use case with the required [repository].
  const RemoveStaffMemberUseCase({required this.repository});

  /// The staff management repository.
  final StaffManagementRepository repository;

  @override
  Future<Either<Failure, void>> call(RemoveStaffParams params) {
    return repository.removeStaffMember(params.id);
  }
}
