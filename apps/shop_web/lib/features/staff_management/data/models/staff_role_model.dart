/// Model class representing a staff role returned from the remote API.
///
/// Handles JSON serialisation/deserialisation and conversion to the
/// domain [StaffRole] entity.
library;

import 'package:shop_web/features/staff_management/domain/entities/staff_role.dart';

/// Data model for a staff role definition.
class StaffRoleModel {
  /// Creates a [StaffRoleModel] with all required fields.
  const StaffRoleModel({
    required this.id,
    required this.name,
    required this.description,
    required this.permissions,
  });

  /// Unique identifier for the role.
  final String id;

  /// Human-readable role name (e.g. "Manager").
  final String name;

  /// Brief description of what this role can do.
  final String description;

  /// List of permission keys associated with this role.
  final List<String> permissions;

  /// Constructs a [StaffRoleModel] from a JSON [map].
  factory StaffRoleModel.fromJson(Map<String, dynamic> map) {
    return StaffRoleModel(
      id: map['id'] as String,
      name: map['name'] as String,
      description: map['description'] as String,
      permissions: List<String>.from(map['permissions'] as List),
    );
  }

  /// Serialises this model to a JSON-compatible [Map].
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'permissions': permissions,
      };

  /// Converts this model to the domain [StaffRole] entity.
  StaffRole toEntity() => StaffRole(
        id: id,
        name: name,
        description: description,
        permissions: permissions,
      );
}
