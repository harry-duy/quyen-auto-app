import 'package:json_annotation/json_annotation.dart';
part 'staff_profile_response.g.dart';

@JsonSerializable()
class StaffProfileResponse {
  final int id;
  final String fullName;
  final String phone;
  final String? email;
  final String? avatarUrl;
  final String role;
  final bool isActive;
  final int? departmentId;
  final String? departmentName;
  final String? position;
  final String? employeeCode;
  final DateTime? createdAt;

  const StaffProfileResponse({
    required this.id,
    required this.fullName,
    required this.phone,
    this.email,
    this.avatarUrl,
    required this.role,
    this.isActive = true,
    this.departmentId,
    this.departmentName,
    this.position,
    this.employeeCode,
    this.createdAt,
  });

  factory StaffProfileResponse.fromJson(Map<String, dynamic> json) =>
      _$StaffProfileResponseFromJson(json);
  Map<String, dynamic> toJson() => _$StaffProfileResponseToJson(this);
}
