/// Domain entity representing a staff invite request.
///
/// Uses [Equatable] for value-based equality comparisons in tests and BLoC.
library;

import 'package:equatable/equatable.dart';

/// Immutable domain entity for an outgoing staff invitation.
class StaffInvite extends Equatable {
  /// Creates a [StaffInvite] with all required fields.
  const StaffInvite({
    required this.email,
    required this.name,
    required this.roleId,
    this.message,
  });

  /// Target email address for the invitation.
  final String email;

  /// Full name of the person being invited.
  final String name;

  /// ID of the role to assign upon acceptance.
  final String roleId;

  /// Optional personalised message to include in the invite email.
  final String? message;

  /// Returns a copy of this entity with optionally overridden fields.
  StaffInvite copyWith({
    String? email,
    String? name,
    String? roleId,
    String? message,
  }) =>
      StaffInvite(
        email: email ?? this.email,
        name: name ?? this.name,
        roleId: roleId ?? this.roleId,
        message: message ?? this.message,
      );

  @override
  List<Object?> get props => [email, name, roleId, message];
}
