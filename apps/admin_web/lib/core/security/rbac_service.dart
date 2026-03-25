import 'package:admin_web/core/security/admin_auth_service.dart';

enum Permission {
  viewCities,
  manageCities,
  viewShops,
  manageShops,
  viewDisputes,
  manageDisputes,
  viewFraud,
  manageFraud,
  viewPayments,
  managePayments,
  viewTrust,
  manageTrust,
  viewAuditLogs,
  viewAnalytics,
  viewSystemHealth,
  manageSystem,
  superAdmin,
}

class RbacService {
  static const Map<AdminRole, List<Permission>> _rolePermissions = {
    AdminRole.superAdmin: Permission.values,
    AdminRole.admin: [
      Permission.viewCities,
      Permission.manageCities,
      Permission.viewShops,
      Permission.manageShops,
      Permission.viewDisputes,
      Permission.manageDisputes,
      Permission.viewFraud,
      Permission.manageFraud,
      Permission.viewPayments,
      Permission.managePayments,
      Permission.viewTrust,
      Permission.manageTrust,
      Permission.viewAuditLogs,
      Permission.viewAnalytics,
      Permission.viewSystemHealth,
      Permission.manageSystem,
    ],
    AdminRole.moderator: [
      Permission.viewCities,
      Permission.viewShops,
      Permission.manageShops,
      Permission.viewDisputes,
      Permission.manageDisputes,
      Permission.viewFraud,
      Permission.viewPayments,
      Permission.viewTrust,
      Permission.viewAuditLogs,
      Permission.viewAnalytics,
    ],
    AdminRole.analyst: [
      Permission.viewCities,
      Permission.viewShops,
      Permission.viewDisputes,
      Permission.viewFraud,
      Permission.viewPayments,
      Permission.viewTrust,
      Permission.viewAuditLogs,
      Permission.viewAnalytics,
      Permission.viewSystemHealth,
    ],
  };

  bool hasPermission(AdminRole role, Permission permission) {
    final permissions = _rolePermissions[role] ?? [];
    return permissions.contains(permission);
  }

  bool canAccess(List<Permission> required, AdminRole userRole) {
    if (required.isEmpty) return true;
    return required.every((p) => hasPermission(userRole, p));
  }

  List<Permission> getPermissionsForRole(AdminRole role) {
    return List.unmodifiable(_rolePermissions[role] ?? []);
  }
}
