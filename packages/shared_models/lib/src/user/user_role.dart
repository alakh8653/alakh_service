/// Defines the role of a user in the system.
enum UserRole {
  customer,
  shopOwner,
  staff,
  admin,
  superAdmin;

  /// Serializes this role to a JSON string.
  String toJson() => name;

  /// Deserializes a role from a JSON string.
  /// Falls back to [UserRole.customer] if the value is unrecognized.
  static UserRole fromJson(String value) =>
      UserRole.values.firstWhere((e) => e.name == value, orElse: () => UserRole.customer);
}
