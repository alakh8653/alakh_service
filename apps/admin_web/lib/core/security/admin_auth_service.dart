import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:admin_web/core/errors/failures.dart';
import 'package:admin_web/core/errors/admin_error_handler.dart';
import 'package:admin_web/core/network/admin_api_client.dart';
import 'package:admin_web/core/network/admin_api_endpoints.dart';
import 'package:admin_web/core/security/admin_session_manager.dart';

enum AdminRole { superAdmin, admin, moderator, analyst }

class AdminUser extends Equatable {
  final String id;
  final String email;
  final String name;
  final AdminRole role;
  final List<String> permissions;

  const AdminUser({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    required this.permissions,
  });

  factory AdminUser.fromJson(Map<String, dynamic> json) {
    return AdminUser(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      role: _parseRole(json['role'] as String? ?? 'analyst'),
      permissions: List<String>.from(json['permissions'] as List? ?? []),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'name': name,
        'role': role.name,
        'permissions': permissions,
      };

  static AdminRole _parseRole(String value) {
    switch (value) {
      case 'superAdmin':
        return AdminRole.superAdmin;
      case 'admin':
        return AdminRole.admin;
      case 'moderator':
        return AdminRole.moderator;
      default:
        return AdminRole.analyst;
    }
  }

  @override
  List<Object?> get props => [id, email, name, role, permissions];
}

class AdminAuthService {
  final AdminApiClient _apiClient;
  final AdminSessionManager _sessionManager;

  AdminAuthService({
    required AdminApiClient apiClient,
    required AdminSessionManager sessionManager,
  })  : _apiClient = apiClient,
        _sessionManager = sessionManager;

  Future<Either<Failure, AdminUser>> login(
    String email,
    String password,
  ) async {
    try {
      final response = await _apiClient.post(
        AdminApiEndpoints.authLogin,
        data: {'email': email, 'password': password},
      );

      final data = response.data as Map<String, dynamic>;
      final token = data['token'] as String;
      final refreshToken = data['refreshToken'] as String;
      final userJson = data['user'] as Map<String, dynamic>;
      final user = AdminUser.fromJson(userJson);

      await _sessionManager.saveSession(token, refreshToken, user);
      return Right(user);
    } catch (e) {
      return Left(AdminErrorHandler.handleDioException(e));
    }
  }

  Future<Either<Failure, Unit>> logout() async {
    try {
      await _apiClient.post(AdminApiEndpoints.authLogout);
      await _sessionManager.clearSession();
      return const Right(unit);
    } catch (e) {
      await _sessionManager.clearSession();
      return const Right(unit);
    }
  }

  Future<Either<Failure, String>> refreshToken() async {
    try {
      final refreshToken = _sessionManager.getRefreshToken();
      if (refreshToken == null) {
        return const Left(UnauthorizedFailure('No refresh token available'));
      }

      final response = await _apiClient.post(
        AdminApiEndpoints.authRefresh,
        data: {'refreshToken': refreshToken},
      );

      final data = response.data as Map<String, dynamic>;
      final newToken = data['token'] as String;
      final newRefresh = data['refreshToken'] as String? ?? refreshToken;
      final user = _sessionManager.getUser();

      if (user != null) {
        await _sessionManager.saveSession(newToken, newRefresh, user);
      }

      return Right(newToken);
    } catch (e) {
      return Left(AdminErrorHandler.handleDioException(e));
    }
  }

  AdminUser? getCurrentUser() => _sessionManager.getUser();

  bool isAuthenticated() => _sessionManager.isSessionValid();
}
