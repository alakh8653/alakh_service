/// BLoC events for the Staff Management feature.
///
/// Each event class represents a distinct user action or system trigger.
library;

import 'package:equatable/equatable.dart';
import 'package:shop_web/features/staff_management/domain/entities/staff_invite.dart';
import 'package:shop_web/features/staff_management/domain/entities/staff_member.dart';

/// Base class for all staff management events.
abstract class StaffManagementEvent extends Equatable {
  const StaffManagementEvent();

  @override
  List<Object?> get props => [];
}

/// Triggers loading of the full staff list along with available roles.
class LoadStaff extends StaffManagementEvent {
  const LoadStaff();
}

/// Triggers loading of the detail view for the staff member with [id].
class LoadStaffDetail extends StaffManagementEvent {
  const LoadStaffDetail({required this.id});

  /// ID of the staff member to load.
  final String id;

  @override
  List<Object?> get props => [id];
}

/// Requests creation of a new [staff] member.
class AddStaff extends StaffManagementEvent {
  const AddStaff({required this.staff});

  /// The staff member entity to create.
  final StaffMember staff;

  @override
  List<Object?> get props => [staff];
}

/// Requests an update to an existing [staff] member.
class UpdateStaff extends StaffManagementEvent {
  const UpdateStaff({required this.staff});

  /// Updated staff member entity.
  final StaffMember staff;

  @override
  List<Object?> get props => [staff];
}

/// Requests removal of the staff member identified by [id].
class RemoveStaff extends StaffManagementEvent {
  const RemoveStaff({required this.id});

  /// ID of the staff member to remove.
  final String id;

  @override
  List<Object?> get props => [id];
}

/// Sends an invitation described by [invite].
class InviteStaff extends StaffManagementEvent {
  const InviteStaff({required this.invite});

  /// Invitation details to dispatch.
  final StaffInvite invite;

  @override
  List<Object?> get props => [invite];
}

/// Requests a schedule update for staff member [id] with the new [schedule].
class UpdateSchedule extends StaffManagementEvent {
  const UpdateSchedule({required this.id, required this.schedule});

  /// ID of the staff member.
  final String id;

  /// New weekly schedule mapping day names to time-slot lists.
  final Map<String, List<String>> schedule;

  @override
  List<Object?> get props => [id, schedule];
}

/// Filters the staff list to members whose names match [query].
class SearchStaff extends StaffManagementEvent {
  const SearchStaff({required this.query});

  /// Free-text search string.
  final String query;

  @override
  List<Object?> get props => [query];
}

/// Filters the staff list to members with the given [role].
class FilterByRole extends StaffManagementEvent {
  const FilterByRole({required this.role});

  /// Role name to filter by, or empty string to clear the filter.
  final String role;

  @override
  List<Object?> get props => [role];
}

/// Filters the staff list to members with the given [status].
class FilterByStatus extends StaffManagementEvent {
  const FilterByStatus({required this.status});

  /// Status value to filter by (active | inactive | invited | suspended).
  final String status;

  @override
  List<Object?> get props => [status];
}
