/// Request model for user registration API call.
class RegisterRequestModel {
  final String name;
  final String email;
  final String phone;
  final String password;

  const RegisterRequestModel({
    required this.name,
    required this.email,
    required this.phone,
    required this.password,
  });

  /// Converts this request to a JSON map for the API call.
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'password': password,
    };
  }

  /// Creates a copy of this model with updated fields.
  RegisterRequestModel copyWith({
    String? name,
    String? email,
    String? phone,
    String? password,
  }) {
    return RegisterRequestModel(
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      password: password ?? this.password,
    );
  }
}
