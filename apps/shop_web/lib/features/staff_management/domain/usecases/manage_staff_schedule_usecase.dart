/// Use case for updating a staff member's weekly schedule.
///
/// Implements [UseCase]<[StaffMember], [ScheduleParams]>.
library;

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:shop_web/core/errors/shop_error_handler.dart';
import 'package:shop_web/features/staff_management/domain/entities/staff_member.dart';
import 'package:shop_web/features/staff_management/domain/repositories/staff_management_repository.dart';

/// Parameters required to update a staff member's schedule.
class ScheduleParams extends Equatable {
  /// Creates [ScheduleParams] with the member [id] and the new [schedule].
  const ScheduleParams({required this.id, required this.schedule});

  /// ID of the staff member whose schedule is being updated.
  final String id;

  /// Weekly schedule mapping day names to lists of time-slot strings.
  final Map<String, List<String>> schedule;

  @override
  List<Object?> get props => [id, schedule];
}

/// Replaces the weekly schedule for a staff member via the repository.
class ManageStaffScheduleUseCase
    implements UseCase<StaffMember, ScheduleParams> {
  /// Creates the use case with the required [repository].
  const ManageStaffScheduleUseCase({required this.repository});

  /// The staff management repository.
  final StaffManagementRepository repository;

  @override
  Future<Either<Failure, StaffMember>> call(ScheduleParams params) {
    return repository.updateStaffSchedule(params.id, params.schedule);
  }
}
