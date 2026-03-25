/// Abstract repository contract for the Staff Management feature.
///
/// All methods return [Either] from `dartz` to represent success or [Failure].
library;

import 'package:dartz/dartz.dart';
import 'package:shop_web/core/errors/shop_error_handler.dart';
import 'package:shop_web/features/staff_management/domain/entities/staff_invite.dart';
import 'package:shop_web/features/staff_management/domain/entities/staff_member.dart';
import 'package:shop_web/features/staff_management/domain/entities/staff_role.dart';

/// Contract that data-layer implementations must fulfil.
abstract class StaffManagementRepository {
  /// Returns the complete list of staff members or a [Failure].
  Future<Either<Failure, List<StaffMember>>> getStaffList();

  /// Returns a single staff member by [id] or a [Failure].
  Future<Either<Failure, StaffMember>> getStaffById(String id);

  /// Persists a new [member] and returns the created entity or a [Failure].
  Future<Either<Failure, StaffMember>> addStaffMember(StaffMember member);

  /// Updates the staff member identified by [id] with [member] data.
  Future<Either<Failure, StaffMember>> updateStaffMember(
    String id,
    StaffMember member,
  );

  /// Permanently removes the staff member with [id] or returns a [Failure].
  Future<Either<Failure, void>> removeStaffMember(String id);

  /// Sends an invitation described by [invite] or returns a [Failure].
  Future<Either<Failure, void>> inviteStaff(StaffInvite invite);

  /// Returns all available [StaffRole] definitions or a [Failure].
  Future<Either<Failure, List<StaffRole>>> getStaffRoles();

  /// Replaces the weekly [schedule] for staff member [id].
  Future<Either<Failure, StaffMember>> updateStaffSchedule(
    String id,
    Map<String, List<String>> schedule,
  );
}
