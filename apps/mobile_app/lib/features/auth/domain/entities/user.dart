import 'package:equatable/equatable.dart';

/// Represents an authenticated user in the domain layer.
class User extends Equatable {
  /// Unique identifier for the user.
  final String id;

  /// Full name of the user.
  final String name;

  /// Email address of the user.
  final String email;

  /// Phone number of the user.
  final String phone;

  /// URL to the user's avatar image.
  final String avatar;

  /// Role of the user (e.g., 'student', 'teacher', 'admin').
  final String role;

  /// Whether the user's account has been verified.
  final bool isVerified;

  /// Timestamp when the user account was created.
  final DateTime createdAt;

  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.avatar,
    required this.role,
    required this.isVerified,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, name, email, phone, avatar, role, isVerified, createdAt];
}
