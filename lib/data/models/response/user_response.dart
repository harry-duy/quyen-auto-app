import 'package:json_annotation/json_annotation.dart';
part 'user_response.g.dart';

@JsonSerializable()
class UserResponse {
  final int     id;
  final String  phone;
  final String? email;
  final String  fullName;
  final String  role;
  final String? companyName;
  final String? avatarUrl;
  final String? accessToken;
  final String? refreshToken;

  const UserResponse({
    required this.id,
    required this.phone,
    this.email,
    required this.fullName,
    required this.role,
    this.companyName,
    this.avatarUrl,
    this.accessToken,
    this.refreshToken,
  });

  factory UserResponse.fromJson(Map<String, dynamic> json) =>
      _$UserResponseFromJson(json);
  Map<String, dynamic> toJson() => _$UserResponseToJson(this);
}
