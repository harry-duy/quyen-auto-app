import 'package:json_annotation/json_annotation.dart';
import 'product_response.dart';
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
class VehicleResponse {
  final int              id;
  final String           plateNumber;
  final String           chassisNumber;
  final DateTime         purchaseDate;
  final ProductResponse? product;

  const VehicleResponse({
    required this.id,
    required this.plateNumber,
    required this.chassisNumber,
    required this.purchaseDate,
    this.product,
  });

  factory VehicleResponse.fromJson(Map<String, dynamic> json) =>
      _$VehicleResponseFromJson(json);
  Map<String, dynamic> toJson() => _$VehicleResponseToJson(this);
}

@JsonSerializable()
class WarrantyRequestResponse {
  final int                    id;
  final VehicleResponse        vehicle;
  final String                 issueDescription;
  final String                 status;
  final DateTime?              scheduledDate;
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
