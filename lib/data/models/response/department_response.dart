import 'package:json_annotation/json_annotation.dart';
part 'department_response.g.dart';

@JsonSerializable()
class DepartmentResponse {
  final int id;
  final String name;
  final String? description;
  final int? managerId;
  final String? managerName;
  final int staffCount;
  final bool isActive;

  const DepartmentResponse({
    required this.id,
    required this.name,
    this.description,
    this.managerId,
    this.managerName,
    this.staffCount = 0,
    this.isActive = true,
  });

  factory DepartmentResponse.fromJson(Map<String, dynamic> json) =>
      _$DepartmentResponseFromJson(json);
  Map<String, dynamic> toJson() => _$DepartmentResponseToJson(this);
}
