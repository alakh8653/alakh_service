/// Use case for inviting a new staff member via email.
///
/// Implements [UseCase]<void, [InviteStaffParams]>.
library;

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:shop_web/core/errors/shop_error_handler.dart';
import 'package:shop_web/features/staff_management/domain/entities/staff_invite.dart';
import 'package:shop_web/features/staff_management/domain/repositories/staff_management_repository.dart';

/// Parameters required to send a staff invitation.
class InviteStaffParams extends Equatable {
  /// Creates [InviteStaffParams] wrapping the [invite] entity.
  const InviteStaffParams({required this.invite});

  /// The invitation details to send.
  final StaffInvite invite;

  @override
  List<Object?> get props => [invite];
}

/// Sends a staff invitation email via the repository.
class InviteStaffUseCase implements UseCase<void, InviteStaffParams> {
  /// Creates the use case with the required [repository].
  const InviteStaffUseCase({required this.repository});

  /// The staff management repository.
  final StaffManagementRepository repository;

  @override
  Future<Either<Failure, void>> call(InviteStaffParams params) {
    return repository.inviteStaff(params.invite);
  }
}
