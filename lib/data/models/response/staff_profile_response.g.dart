// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'staff_profile_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StaffProfileResponse _$StaffProfileResponseFromJson(
  Map<String, dynamic> json,
) => StaffProfileResponse(
  id: (json['id'] as num).toInt(),
  fullName: json['fullName'] as String,
  phone: json['phone'] as String,
  email: json['email'] as String?,
  avatarUrl: json['avatarUrl'] as String?,
  role: json['role'] as String,
  isActive: json['isActive'] as bool? ?? true,
  departmentId: (json['departmentId'] as num?)?.toInt(),
  departmentName: json['departmentName'] as String?,
  position: json['position'] as String?,
  employeeCode: json['employeeCode'] as String?,
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$StaffProfileResponseToJson(
  StaffProfileResponse instance,
) => <String, dynamic>{
  'id': instance.id,
  'fullName': instance.fullName,
  'phone': instance.phone,
  'email': instance.email,
  'avatarUrl': instance.avatarUrl,
  'role': instance.role,
  'isActive': instance.isActive,
  'departmentId': instance.departmentId,
  'departmentName': instance.departmentName,
  'position': instance.position,
  'employeeCode': instance.employeeCode,
  'createdAt': instance.createdAt?.toIso8601String(),
};
