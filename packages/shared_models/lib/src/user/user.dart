import 'package:equatable/equatable.dart';

import 'user_role.dart';

/// Represents an authenticated user of the platform.
class User extends Equatable {
  /// Unique identifier for the user.
  final String id;

  /// Full display name.
  final String name;

  /// Email address (unique per platform).
  final String email;

  /// Optional mobile phone number in E.164 format.
  final String? phone;

  /// Optional URL to the user's profile avatar image.
  final String? avatar;

  /// The role that determines this user's permissions.
  final UserRole role;

  /// Whether the user's email or phone has been verified.
  final bool isVerified;

  /// UTC timestamp at which the account was created.
  final DateTime createdAt;

  const User({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.avatar,
    required this.role,
    required this.isVerified,
    required this.createdAt,
  });

  /// Creates a [User] from a JSON map.
  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json['id'] as String,
        name: json['name'] as String,
        email: json['email'] as String,
        phone: json['phone'] as String?,
        avatar: json['avatar'] as String?,
        role: UserRole.fromJson(json['role'] as String),
        isVerified: json['isVerified'] as bool,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );

  /// Converts this instance to a JSON map.
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        if (phone != null) 'phone': phone,
        if (avatar != null) 'avatar': avatar,
        'role': role.toJson(),
        'isVerified': isVerified,
        'createdAt': createdAt.toIso8601String(),
      };

  /// Returns a copy with optionally overridden fields.
  User copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? avatar,
    UserRole? role,
    bool? isVerified,
    DateTime? createdAt,
  }) =>
      User(
        id: id ?? this.id,
        name: name ?? this.name,
        email: email ?? this.email,
        phone: phone ?? this.phone,
        avatar: avatar ?? this.avatar,
        role: role ?? this.role,
        isVerified: isVerified ?? this.isVerified,
        createdAt: createdAt ?? this.createdAt,
      );

  @override
  List<Object?> get props =>
      [id, name, email, phone, avatar, role, isVerified, createdAt];

  @override
  String toString() =>
      'User(id: $id, name: $name, email: $email, phone: $phone, '
      'avatar: $avatar, role: $role, isVerified: $isVerified, createdAt: $createdAt)';
}
