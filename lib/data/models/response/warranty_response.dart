import 'package:json_annotation/json_annotation.dart';
part 'warranty_response.g.dart';

@JsonSerializable()
class WarrantyLogResponse {
  final int      id;
  final String   action;
  final String?  note;
  final DateTime createdAt;

  const WarrantyLogResponse({
    required this.id,
    required this.action,
    this.note,
    required this.createdAt,
  });

  factory WarrantyLogResponse.fromJson(Map<String, dynamic> json) =>
      _$WarrantyLogResponseFromJson(json);
  Map<String, dynamic> toJson() => _$WarrantyLogResponseToJson(this);
}

@JsonSerializable()
class VehicleInfo {
  final int     id;
  final String  plateNumber;
  final String  chassisNumber;
  final String? purchaseDate;

  const VehicleInfo({
    required this.id,
    required this.plateNumber,
    required this.chassisNumber,
    this.purchaseDate,
  });

  factory VehicleInfo.fromJson(Map<String, dynamic> json) =>
      _$VehicleInfoFromJson(json);
  Map<String, dynamic> toJson() => _$VehicleInfoToJson(this);
}

@JsonSerializable()
class WarrantyRequestResponse {
  final int                    id;
  final VehicleInfo            vehicle;
  final String                 issueDescription;
  final String                 status;
  final String?                scheduledDate;
  final List<WarrantyLogResponse> logs;

  const WarrantyRequestResponse({
    required this.id,
    required this.vehicle,
    required this.issueDescription,
    required this.status,
    this.scheduledDate,
    required this.logs,
  });

  factory WarrantyRequestResponse.fromJson(Map<String, dynamic> json) =>
      _$WarrantyRequestResponseFromJson(json);
  Map<String, dynamic> toJson() => _$WarrantyRequestResponseToJson(this);
}
