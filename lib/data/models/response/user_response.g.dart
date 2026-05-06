// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserResponse _$UserResponseFromJson(Map<String, dynamic> json) => UserResponse(
  id: (json['id'] as num).toInt(),
  phone: json['phone'] as String,
  email: json['email'] as String?,
  fullName: json['fullName'] as String,
  role: json['role'] as String,
  companyName: json['companyName'] as String?,
  avatarUrl: json['avatarUrl'] as String?,
  accessToken: json['accessToken'] as String?,
  refreshToken: json['refreshToken'] as String?,
);

Map<String, dynamic> _$UserResponseToJson(UserResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'phone': instance.phone,
      'email': instance.email,
      'fullName': instance.fullName,
      'role': instance.role,
      'companyName': instance.companyName,
      'avatarUrl': instance.avatarUrl,
      'accessToken': instance.accessToken,
      'refreshToken': instance.refreshToken,
    };
