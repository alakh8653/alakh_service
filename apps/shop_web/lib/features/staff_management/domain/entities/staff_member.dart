/// Domain entity representing a staff member.
///
/// Uses [Equatable] for value-based equality comparisons in tests and BLoC.
library;

import 'package:equatable/equatable.dart';

/// Immutable domain entity for a shop staff member.
class StaffMember extends Equatable {
  /// Creates a [StaffMember] entity with all required fields.
  const StaffMember({
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

  /// Unique identifier.
  final String id;

  /// Full display name.
  final String name;

  /// Contact email address.
  final String email;

  /// Contact phone number.
  final String phone;

  /// Role name (e.g. "Manager").
  final String role;

  /// Account status: active | inactive | invited | suspended.
  final String status;

  /// Optional URL to the avatar image.
  final String? avatarUrl;

  /// Permission keys granted to this member.
  final List<String> permissions;

  /// Date the member joined the shop.
  final DateTime joinedAt;

  /// Weekly schedule mapping day names to lists of time-slot strings.
  final Map<String, List<String>>? schedule;

  /// Returns a copy of this entity with optionally overridden fields.
  StaffMember copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? role,
    String? status,
    String? avatarUrl,
    List<String>? permissions,
    DateTime? joinedAt,
    Map<String, List<String>>? schedule,
  }) =>
      StaffMember(
        id: id ?? this.id,
        name: name ?? this.name,
        email: email ?? this.email,
        phone: phone ?? this.phone,
        role: role ?? this.role,
        status: status ?? this.status,
        avatarUrl: avatarUrl ?? this.avatarUrl,
        permissions: permissions ?? this.permissions,
        joinedAt: joinedAt ?? this.joinedAt,
        schedule: schedule ?? this.schedule,
      );

  @override
  List<Object?> get props => [
        id,
        name,
        email,
        phone,
        role,
        status,
        avatarUrl,
        permissions,
        joinedAt,
        schedule,
      ];
}
