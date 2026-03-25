/// Concrete implementation of [StaffManagementRepository].
///
/// Bridges the data layer ([StaffManagementRemoteDataSource]) to the domain
/// layer, translating exceptions into typed [Failure] objects.
library;

import 'package:dartz/dartz.dart';
import 'package:shop_web/core/errors/shop_error_handler.dart';
import 'package:shop_web/core/errors/shop_exceptions.dart';
import 'package:shop_web/features/staff_management/data/datasources/staff_management_remote_datasource.dart';
import 'package:shop_web/features/staff_management/data/models/staff_invite_model.dart';
import 'package:shop_web/features/staff_management/data/models/staff_member_model.dart';
import 'package:shop_web/features/staff_management/domain/entities/staff_invite.dart';
import 'package:shop_web/features/staff_management/domain/entities/staff_member.dart';
import 'package:shop_web/features/staff_management/domain/entities/staff_role.dart';
import 'package:shop_web/features/staff_management/domain/repositories/staff_management_repository.dart';

/// Implementation that delegates to [StaffManagementRemoteDataSource].
class StaffManagementRepositoryImpl implements StaffManagementRepository {
  /// Creates the repository with the required [remoteDataSource].
  const StaffManagementRepositoryImpl({required this.remoteDataSource});

  /// The remote data source for all API calls.
  final StaffManagementRemoteDataSource remoteDataSource;

  @override
  Future<Either<Failure, List<StaffMember>>> getStaffList() async {
    try {
      final models = await remoteDataSource.getStaffList();
      return Right(models.map((m) => m.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, StaffMember>> getStaffById(String id) async {
    try {
      final model = await remoteDataSource.getStaffById(id);
      return Right(model.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, StaffMember>> addStaffMember(
      StaffMember member) async {
    try {
      final model = await remoteDataSource.addStaffMember(
        StaffMemberModel(
          id: member.id,
          name: member.name,
          email: member.email,
          phone: member.phone,
          role: member.role,
          status: member.status,
          avatarUrl: member.avatarUrl,
          permissions: member.permissions,
          joinedAt: member.joinedAt,
          schedule: member.schedule,
        ),
      );
      return Right(model.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, StaffMember>> updateStaffMember(
      String id, StaffMember member) async {
    try {
      final model = await remoteDataSource.updateStaffMember(
        id,
        StaffMemberModel(
          id: member.id,
          name: member.name,
          email: member.email,
          phone: member.phone,
          role: member.role,
          status: member.status,
          avatarUrl: member.avatarUrl,
          permissions: member.permissions,
          joinedAt: member.joinedAt,
          schedule: member.schedule,
        ),
      );
      return Right(model.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> removeStaffMember(String id) async {
    try {
      await remoteDataSource.removeStaffMember(id);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> inviteStaff(StaffInvite invite) async {
    try {
      await remoteDataSource.inviteStaff(StaffInviteModel.fromEntity(invite));
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<StaffRole>>> getStaffRoles() async {
    try {
      final models = await remoteDataSource.getStaffRoles();
      return Right(models.map((m) => m.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, StaffMember>> updateStaffSchedule(
      String id, Map<String, List<String>> schedule) async {
    try {
      final model =
          await remoteDataSource.updateStaffSchedule(id, schedule);
      return Right(model.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    }
  }
}
