// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'department_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DepartmentResponse _$DepartmentResponseFromJson(Map<String, dynamic> json) =>
    DepartmentResponse(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      description: json['description'] as String?,
      managerId: (json['managerId'] as num?)?.toInt(),
      managerName: json['managerName'] as String?,
      staffCount: (json['staffCount'] as num?)?.toInt() ?? 0,
      isActive: json['isActive'] as bool? ?? true,
    );

Map<String, dynamic> _$DepartmentResponseToJson(DepartmentResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'managerId': instance.managerId,
      'managerName': instance.managerName,
      'staffCount': instance.staffCount,
      'isActive': instance.isActive,
    };
