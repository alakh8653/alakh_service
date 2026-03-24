import 'package:freezed_annotation/freezed_annotation.dart';
import 'enums/user_role.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

@freezed
class UserModel with _$UserModel {
  const factory UserModel({
    required String id,
    required String firstName,
    required String lastName,
    required String email,
    String? phone,
    @Default(UserRole.customer) UserRole role,
    String? avatarUrl,
    @Default(false) bool isVerified,
    DateTime? createdAt,
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);
}
