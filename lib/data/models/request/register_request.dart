import 'package:json_annotation/json_annotation.dart';
part 'register_request.g.dart';

@JsonSerializable()
class RegisterRequest {
  final String  phone;
  final String  fullName;
  final String? email;
  final String? companyName;
  final String  password;

  const RegisterRequest({
    required this.phone,
    required this.fullName,
    this.email,
    this.companyName,
    required this.password,
  });

  factory RegisterRequest.fromJson(Map<String, dynamic> json) =>
      _$RegisterRequestFromJson(json);
  Map<String, dynamic> toJson() => _$RegisterRequestToJson(this);
}
