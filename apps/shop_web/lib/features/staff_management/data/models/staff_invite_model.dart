/// Model class representing a staff invite request payload.
///
/// Used when sending an invitation to a new staff member via the API.
library;

import 'package:shop_web/features/staff_management/domain/entities/staff_invite.dart';

/// Data model for a staff invitation.
class StaffInviteModel {
  /// Creates a [StaffInviteModel] with all required fields.
  const StaffInviteModel({
    required this.email,
    required this.name,
    required this.roleId,
    this.message,
  });

  /// Email address to send the invitation to.
  final String email;

  /// Full name of the person being invited.
  final String name;

  /// ID of the role to assign on acceptance.
  final String roleId;

  /// Optional personalised message included in the invite email.
  final String? message;

  /// Constructs a [StaffInviteModel] from a JSON [map].
  factory StaffInviteModel.fromJson(Map<String, dynamic> map) {
    return StaffInviteModel(
      email: map['email'] as String,
      name: map['name'] as String,
      roleId: map['role_id'] as String,
      message: map['message'] as String?,
    );
  }

  /// Serialises this model to a JSON-compatible [Map].
  Map<String, dynamic> toJson() => {
        'email': email,
        'name': name,
        'role_id': roleId,
        if (message != null) 'message': message,
      };

  /// Converts this model to the domain [StaffInvite] entity.
  StaffInvite toEntity() => StaffInvite(
        email: email,
        name: name,
        roleId: roleId,
        message: message,
      );

  /// Creates a [StaffInviteModel] from a domain [StaffInvite] entity.
  factory StaffInviteModel.fromEntity(StaffInvite entity) {
    return StaffInviteModel(
      email: entity.email,
      name: entity.name,
      roleId: entity.roleId,
      message: entity.message,
    );
  }
}
