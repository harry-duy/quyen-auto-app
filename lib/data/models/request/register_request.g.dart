// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'register_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RegisterRequest _$RegisterRequestFromJson(Map<String, dynamic> json) =>
    RegisterRequest(
      phone: json['phone'] as String,
      fullName: json['fullName'] as String,
      email: json['email'] as String?,
      companyName: json['companyName'] as String?,
      password: json['password'] as String,
    );

Map<String, dynamic> _$RegisterRequestToJson(RegisterRequest instance) =>
    <String, dynamic>{
      'phone': instance.phone,
      'fullName': instance.fullName,
      'email': instance.email,
      'companyName': instance.companyName,
      'password': instance.password,
    };
