/// Model class representing a staff member returned from the remote API.
///
/// Handles JSON serialisation/deserialisation and conversion to the
/// domain [StaffMember] entity.
library;

import 'package:shop_web/features/staff_management/domain/entities/staff_member.dart';

/// Data model for a shop staff member.
class StaffMemberModel {
  /// Creates a [StaffMemberModel] with all required fields.
  const StaffMemberModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    required this.status,
    required this.permissions,
    required this.joinedAt,
    this.avatarUrl,
    this.schedule,
  });

  /// Unique identifier for the staff member.
  final String id;

  /// Full display name.
  final String name;

  /// Contact email address.
  final String email;

  /// Contact phone number.
  final String phone;

  /// Role name (e.g. "Manager", "Cashier").
  final String role;

  /// Account status: active | inactive | invited | suspended.
  final String status;

  /// Optional URL to the staff member's avatar image.
  final String? avatarUrl;

  /// List of permission keys granted to this member.
  final List<String> permissions;

  /// Date the member joined the shop.
  final DateTime joinedAt;

  /// Weekly schedule mapping day names to lists of time-slot strings.
  final Map<String, List<String>>? schedule;

  /// Constructs a [StaffMemberModel] from a JSON [map].
  factory StaffMemberModel.fromJson(Map<String, dynamic> map) {
    return StaffMemberModel(
      id: map['id'] as String,
      name: map['name'] as String,
      email: map['email'] as String,
      phone: map['phone'] as String,
      role: map['role'] as String,
      status: map['status'] as String,
      avatarUrl: map['avatar_url'] as String?,
      permissions: List<String>.from(map['permissions'] as List),
      joinedAt: DateTime.parse(map['joined_at'] as String),
      schedule: map['schedule'] != null
          ? (map['schedule'] as Map<String, dynamic>).map(
              (k, v) => MapEntry(k, List<String>.from(v as List)),
            )
          : null,
    );
  }

  /// Serialises this model to a JSON-compatible [Map].
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'phone': phone,
        'role': role,
        'status': status,
        'avatar_url': avatarUrl,
        'permissions': permissions,
        'joined_at': joinedAt.toIso8601String(),
        'schedule': schedule,
      };

  /// Converts this model to the domain [StaffMember] entity.
  StaffMember toEntity() => StaffMember(
        id: id,
        name: name,
        email: email,
        phone: phone,
        role: role,
        status: status,
        avatarUrl: avatarUrl,
        permissions: permissions,
        joinedAt: joinedAt,
        schedule: schedule,
      );
}
