/// Domain entity representing a staff role.
///
/// Uses [Equatable] for value-based equality comparisons in tests and BLoC.
library;

import 'package:equatable/equatable.dart';

/// Immutable domain entity for a role that can be assigned to staff.
class StaffRole extends Equatable {
  /// Creates a [StaffRole] with all required fields.
  const StaffRole({
    required this.id,
    required this.name,
    required this.description,
    required this.permissions,
  });

  /// Unique identifier for the role.
  final String id;

  /// Human-readable role name.
  final String name;

  /// Description of what this role allows.
  final String description;

  /// List of permission keys associated with this role.
  final List<String> permissions;

  /// Returns a copy of this entity with optionally overridden fields.
  StaffRole copyWith({
    String? id,
    String? name,
    String? description,
    List<String>? permissions,
  }) =>
      StaffRole(
        id: id ?? this.id,
        name: name ?? this.name,
        description: description ?? this.description,
        permissions: permissions ?? this.permissions,
      );

  @override
  List<Object?> get props => [id, name, description, permissions];
}
