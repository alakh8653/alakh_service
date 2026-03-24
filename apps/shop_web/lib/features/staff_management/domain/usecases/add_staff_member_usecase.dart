/// Use case for adding a new staff member.
///
/// Implements [UseCase]<[StaffMember], [AddStaffParams]>.
library;

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:shop_web/core/errors/shop_error_handler.dart';
import 'package:shop_web/features/staff_management/domain/entities/staff_member.dart';
import 'package:shop_web/features/staff_management/domain/repositories/staff_management_repository.dart';

/// Parameters required to add a new staff member.
class AddStaffParams extends Equatable {
  /// Creates [AddStaffParams] with the [member] to persist.
  const AddStaffParams({required this.member});

  /// The staff member entity to create.
  final StaffMember member;

  @override
  List<Object?> get props => [member];
}

/// Persists a new staff member via the repository.
class AddStaffMemberUseCase implements UseCase<StaffMember, AddStaffParams> {
  /// Creates the use case with the required [repository].
  const AddStaffMemberUseCase({required this.repository});

  /// The staff management repository.
  final StaffManagementRepository repository;

  @override
  Future<Either<Failure, StaffMember>> call(AddStaffParams params) {
    return repository.addStaffMember(params.member);
  }
}
