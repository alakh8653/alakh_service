/// BLoC implementation for the Staff Management feature.
///
/// Orchestrates all staff-related use cases and emits typed states
/// consumed by the presentation layer.
library;

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shop_web/features/staff_management/domain/usecases/add_staff_member_usecase.dart';
import 'package:shop_web/features/staff_management/domain/usecases/get_staff_list_usecase.dart';
import 'package:shop_web/features/staff_management/domain/usecases/invite_staff_usecase.dart';
import 'package:shop_web/features/staff_management/domain/usecases/manage_staff_schedule_usecase.dart';
import 'package:shop_web/features/staff_management/domain/usecases/remove_staff_member_usecase.dart';
import 'package:shop_web/features/staff_management/domain/usecases/update_staff_member_usecase.dart';
import 'package:shop_web/features/staff_management/domain/repositories/staff_management_repository.dart';
import 'package:shop_web/core/errors/shop_error_handler.dart';
import 'staff_management_event.dart';
import 'staff_management_state.dart';

/// BLoC responsible for the staff management feature.
class StaffManagementBloc
    extends Bloc<StaffManagementEvent, StaffManagementState> {
  /// Creates the BLoC with all required use cases.
  StaffManagementBloc({
    required this.getStaffList,
    required this.addStaffMember,
    required this.updateStaffMember,
    required this.removeStaffMember,
    required this.inviteStaff,
    required this.manageStaffSchedule,
    required this.repository,
  }) : super(const StaffManagementInitial()) {
    on<LoadStaff>(_onLoadStaff);
    on<LoadStaffDetail>(_onLoadStaffDetail);
    on<AddStaff>(_onAddStaff);
    on<UpdateStaff>(_onUpdateStaff);
    on<RemoveStaff>(_onRemoveStaff);
    on<InviteStaff>(_onInviteStaff);
    on<UpdateSchedule>(_onUpdateSchedule);
    on<SearchStaff>(_onSearchStaff);
    on<FilterByRole>(_onFilterByRole);
    on<FilterByStatus>(_onFilterByStatus);
  }

  final GetStaffListUseCase getStaffList;
  final AddStaffMemberUseCase addStaffMember;
  final UpdateStaffMemberUseCase updateStaffMember;
  final RemoveStaffMemberUseCase removeStaffMember;
  final InviteStaffUseCase inviteStaff;
  final ManageStaffScheduleUseCase manageStaffSchedule;

  /// Direct repository access used for roles and detail queries.
  final StaffManagementRepository repository;

  Future<void> _onLoadStaff(
      LoadStaff event, Emitter<StaffManagementState> emit) async {
    emit(const StaffManagementLoading());
    final staffResult = await getStaffList(const NoParams());
    final rolesResult = await repository.getStaffRoles();

    staffResult.fold(
      (failure) => emit(StaffManagementError(message: failure.message)),
      (staff) => rolesResult.fold(
        (failure) => emit(StaffManagementError(message: failure.message)),
        (roles) => emit(StaffManagementLoaded(staffList: staff, roles: roles)),
      ),
    );
  }

  Future<void> _onLoadStaffDetail(
      LoadStaffDetail event, Emitter<StaffManagementState> emit) async {
    emit(const StaffManagementLoading());
    final result = await repository.getStaffById(event.id);
    result.fold(
      (failure) => emit(StaffManagementError(message: failure.message)),
      (member) => emit(StaffDetailLoaded(staffMember: member)),
    );
  }

  Future<void> _onAddStaff(
      AddStaff event, Emitter<StaffManagementState> emit) async {
    emit(const StaffActionInProgress(action: 'adding'));
    final result = await addStaffMember(AddStaffParams(member: event.staff));
    result.fold(
      (failure) => emit(StaffManagementError(message: failure.message)),
      (_) {
        emit(const StaffActionSuccess(message: 'Staff member added.'));
        add(const LoadStaff());
      },
    );
  }

  Future<void> _onUpdateStaff(
      UpdateStaff event, Emitter<StaffManagementState> emit) async {
    emit(const StaffActionInProgress(action: 'updating'));
    final result = await updateStaffMember(
        UpdateStaffParams(id: event.staff.id, member: event.staff));
    result.fold(
      (failure) => emit(StaffManagementError(message: failure.message)),
      (_) {
        emit(const StaffActionSuccess(message: 'Staff member updated.'));
        add(const LoadStaff());
      },
    );
  }

  Future<void> _onRemoveStaff(
      RemoveStaff event, Emitter<StaffManagementState> emit) async {
    emit(const StaffActionInProgress(action: 'removing'));
    final result =
        await removeStaffMember(RemoveStaffParams(id: event.id));
    result.fold(
      (failure) => emit(StaffManagementError(message: failure.message)),
      (_) {
        emit(const StaffActionSuccess(message: 'Staff member removed.'));
        add(const LoadStaff());
      },
    );
  }

  Future<void> _onInviteStaff(
      InviteStaff event, Emitter<StaffManagementState> emit) async {
    emit(const StaffActionInProgress(action: 'inviting'));
    final result =
        await inviteStaff(InviteStaffParams(invite: event.invite));
    result.fold(
      (failure) => emit(StaffManagementError(message: failure.message)),
      (_) => emit(const StaffActionSuccess(message: 'Invitation sent.')),
    );
  }

  Future<void> _onUpdateSchedule(
      UpdateSchedule event, Emitter<StaffManagementState> emit) async {
    emit(const StaffActionInProgress(action: 'saving schedule'));
    final result = await manageStaffSchedule(
        ScheduleParams(id: event.id, schedule: event.schedule));
    result.fold(
      (failure) => emit(StaffManagementError(message: failure.message)),
      (member) {
        emit(const StaffActionSuccess(message: 'Schedule updated.'));
        emit(StaffDetailLoaded(staffMember: member));
      },
    );
  }

  void _onSearchStaff(
      SearchStaff event, Emitter<StaffManagementState> emit) {
    final current = state;
    if (current is StaffManagementLoaded) {
      emit(current.copyWith(searchQuery: event.query));
    }
  }

  void _onFilterByRole(
      FilterByRole event, Emitter<StaffManagementState> emit) {
    final current = state;
    if (current is StaffManagementLoaded) {
      emit(current.copyWith(roleFilter: event.role));
    }
  }

  void _onFilterByStatus(
      FilterByStatus event, Emitter<StaffManagementState> emit) {
    final current = state;
    if (current is StaffManagementLoaded) {
      emit(current.copyWith(statusFilter: event.status));
    }
  }
}
