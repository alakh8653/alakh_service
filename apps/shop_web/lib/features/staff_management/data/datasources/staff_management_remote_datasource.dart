/// Remote data source for Staff Management.
///
/// Defines the contract and provides the concrete implementation that
/// communicates with the backend via [ShopApiClient].
library;

import 'package:shop_web/core/errors/shop_exceptions.dart';
import 'package:shop_web/core/network/shop_api_client.dart';
import 'package:shop_web/core/network/shop_api_endpoints.dart';
import 'package:shop_web/features/staff_management/data/models/staff_invite_model.dart';
import 'package:shop_web/features/staff_management/data/models/staff_member_model.dart';
import 'package:shop_web/features/staff_management/data/models/staff_role_model.dart';

/// Contract for the staff management remote data source.
abstract class StaffManagementRemoteDataSource {
  /// Retrieves the full list of staff members.
  Future<List<StaffMemberModel>> getStaffList();

  /// Retrieves a single staff member by [id].
  Future<StaffMemberModel> getStaffById(String id);

  /// Adds a new [model] to the staff roster.
  Future<StaffMemberModel> addStaffMember(StaffMemberModel model);

  /// Updates an existing staff member identified by [id] with [model] data.
  Future<StaffMemberModel> updateStaffMember(String id, StaffMemberModel model);

  /// Permanently removes the staff member with [id].
  Future<void> removeStaffMember(String id);

  /// Sends an invitation email described by [invite].
  Future<void> inviteStaff(StaffInviteModel invite);

  /// Retrieves the list of available staff roles.
  Future<List<StaffRoleModel>> getStaffRoles();

  /// Replaces the weekly [schedule] for the staff member with [id].
  Future<StaffMemberModel> updateStaffSchedule(
    String id,
    Map<String, List<String>> schedule,
  );
}

/// Concrete implementation backed by [ShopApiClient].
class StaffManagementRemoteDataSourceImpl
    implements StaffManagementRemoteDataSource {
  /// Creates the data source with the given [apiClient].
  const StaffManagementRemoteDataSourceImpl({required this.apiClient});

  /// HTTP client used for all remote calls.
  final ShopApiClient apiClient;

  @override
  Future<List<StaffMemberModel>> getStaffList() async {
    try {
      final response = await apiClient.get(ShopApiEndpoints.staff);
      final list = response['data'] as List;
      return list
          .map((e) => StaffMemberModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<StaffMemberModel> getStaffById(String id) async {
    try {
      final response =
          await apiClient.get(ShopApiEndpoints.staffDetail(id));
      return StaffMemberModel.fromJson(
          response['data'] as Map<String, dynamic>);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<StaffMemberModel> addStaffMember(StaffMemberModel model) async {
    try {
      final response =
          await apiClient.post(ShopApiEndpoints.staff, body: model.toJson());
      return StaffMemberModel.fromJson(
          response['data'] as Map<String, dynamic>);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<StaffMemberModel> updateStaffMember(
      String id, StaffMemberModel model) async {
    try {
      final response = await apiClient.put(
        ShopApiEndpoints.staffDetail(id),
        body: model.toJson(),
      );
      return StaffMemberModel.fromJson(
          response['data'] as Map<String, dynamic>);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> removeStaffMember(String id) async {
    try {
      await apiClient.delete(ShopApiEndpoints.staffDetail(id));
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> inviteStaff(StaffInviteModel invite) async {
    try {
      await apiClient.post(ShopApiEndpoints.staffInvite,
          body: invite.toJson());
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<StaffRoleModel>> getStaffRoles() async {
    try {
      final response = await apiClient.get(ShopApiEndpoints.staffRoles);
      final list = response['data'] as List;
      return list
          .map((e) => StaffRoleModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<StaffMemberModel> updateStaffSchedule(
      String id, Map<String, List<String>> schedule) async {
    try {
      final response = await apiClient.put(
        ShopApiEndpoints.staffSchedule(id),
        body: {'schedule': schedule},
      );
      return StaffMemberModel.fromJson(
          response['data'] as Map<String, dynamic>);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
