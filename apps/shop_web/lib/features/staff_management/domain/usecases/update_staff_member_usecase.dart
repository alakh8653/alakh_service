/// Use case for updating an existing staff member.
///
/// Implements [UseCase]<[StaffMember], [UpdateStaffParams]>.
library;

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:shop_web/core/errors/shop_error_handler.dart';
import 'package:shop_web/features/staff_management/domain/entities/staff_member.dart';
import 'package:shop_web/features/staff_management/domain/repositories/staff_management_repository.dart';

/// Parameters required to update an existing staff member.
class UpdateStaffParams extends Equatable {
  /// Creates [UpdateStaffParams] with the target [id] and updated [member].
  const UpdateStaffParams({required this.id, required this.member});

  /// ID of the staff member to update.
  final String id;

  /// Updated staff member entity data.
  final StaffMember member;

  @override
  List<Object?> get props => [id, member];
}

/// Updates an existing staff member via the repository.
class UpdateStaffMemberUseCase
    implements UseCase<StaffMember, UpdateStaffParams> {
  /// Creates the use case with the required [repository].
  const UpdateStaffMemberUseCase({required this.repository});

  /// The staff management repository.
  final StaffManagementRepository repository;

  @override
  Future<Either<Failure, StaffMember>> call(UpdateStaffParams params) {
    return repository.updateStaffMember(params.id, params.member);
  }
}
