/// BLoC states for the Staff Management feature.
///
/// Each state class carries the data required to render the UI.
library;

import 'package:equatable/equatable.dart';
import 'package:shop_web/features/staff_management/domain/entities/staff_member.dart';
import 'package:shop_web/features/staff_management/domain/entities/staff_role.dart';

/// Base class for all staff management states.
abstract class StaffManagementState extends Equatable {
  const StaffManagementState();

  @override
  List<Object?> get props => [];
}

/// Initial, uninitialised state before any event is dispatched.
class StaffManagementInitial extends StaffManagementState {
  const StaffManagementInitial();
}

/// Emitted while an async operation (list load, action) is in progress.
class StaffManagementLoading extends StaffManagementState {
  const StaffManagementLoading();
}

/// Emitted when the staff list and roles have been successfully loaded.
class StaffManagementLoaded extends StaffManagementState {
  const StaffManagementLoaded({
    required this.staffList,
    required this.roles,
    this.searchQuery = '',
    this.roleFilter = '',
    this.statusFilter = '',
  });

  /// Full unfiltered staff roster.
  final List<StaffMember> staffList;

  /// Available role definitions.
  final List<StaffRole> roles;

  /// Active search query; empty string means no filter.
  final String searchQuery;

  /// Active role filter; empty string means no filter.
  final String roleFilter;

  /// Active status filter; empty string means no filter.
  final String statusFilter;

  /// Returns the staff list after applying all active filters.
  List<StaffMember> get filteredStaff {
    return staffList.where((m) {
      final matchesQuery = searchQuery.isEmpty ||
          m.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
          m.email.toLowerCase().contains(searchQuery.toLowerCase());
      final matchesRole = roleFilter.isEmpty || m.role == roleFilter;
      final matchesStatus =
          statusFilter.isEmpty || m.status == statusFilter;
      return matchesQuery && matchesRole && matchesStatus;
    }).toList();
  }

  /// Returns a copy with optionally overridden fields.
  StaffManagementLoaded copyWith({
    List<StaffMember>? staffList,
    List<StaffRole>? roles,
    String? searchQuery,
    String? roleFilter,
    String? statusFilter,
  }) =>
      StaffManagementLoaded(
        staffList: staffList ?? this.staffList,
        roles: roles ?? this.roles,
        searchQuery: searchQuery ?? this.searchQuery,
        roleFilter: roleFilter ?? this.roleFilter,
        statusFilter: statusFilter ?? this.statusFilter,
      );

  @override
  List<Object?> get props =>
      [staffList, roles, searchQuery, roleFilter, statusFilter];
}

/// Emitted when a list or action operation fails.
class StaffManagementError extends StaffManagementState {
  const StaffManagementError({required this.message});

  /// Human-readable error description.
  final String message;

  @override
  List<Object?> get props => [message];
}

/// Emitted when a single staff member's detail has been loaded.
class StaffDetailLoaded extends StaffManagementState {
  const StaffDetailLoaded({required this.staffMember});

  /// The loaded staff member entity.
  final StaffMember staffMember;

  @override
  List<Object?> get props => [staffMember];
}

/// Emitted while a create / update / remove / invite action is in progress.
class StaffActionInProgress extends StaffManagementState {
  const StaffActionInProgress({required this.action});

  /// Short description of the action being performed (e.g. "removing").
  final String action;

  @override
  List<Object?> get props => [action];
}

/// Emitted when a create / update / remove / invite action succeeds.
class StaffActionSuccess extends StaffManagementState {
  const StaffActionSuccess({required this.message});

  /// Success message to display to the user.
  final String message;

  @override
  List<Object?> get props => [message];
}
