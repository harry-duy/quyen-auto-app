import 'package:json_annotation/json_annotation.dart';
part 'warranty_response.g.dart';

@JsonSerializable()
class WarrantyLogResponse {
  final int id;
  final String action;
  final String? note;
  final String? performedBy;
  final DateTime createdAt;

  const WarrantyLogResponse({
    required this.id,
    required this.action,
    this.note,
    this.performedBy,
    required this.createdAt,
  });

  factory WarrantyLogResponse.fromJson(Map<String, dynamic> json) =>
      _$WarrantyLogResponseFromJson(json);
  Map<String, dynamic> toJson() => _$WarrantyLogResponseToJson(this);
}

@JsonSerializable()
class VehicleResponse {
  final int id;
  final int ownerId;
  final String ownerName;
  final int? productId;
  final String? productName;
  final String plateNumber;
  final String chassisNumber;
  final String purchaseDate;
  final String? contractCode;
  final String? warrantyExpiryDate;
  final DateTime createdAt;

  const VehicleResponse({
    required this.id,
    required this.ownerId,
    required this.ownerName,
    this.productId,
    this.productName,
    required this.plateNumber,
    required this.chassisNumber,
    required this.purchaseDate,
    this.contractCode,
    this.warrantyExpiryDate,
    required this.createdAt,
  });

  factory VehicleResponse.fromJson(Map<String, dynamic> json) =>
      _$VehicleResponseFromJson(json);
  Map<String, dynamic> toJson() => _$VehicleResponseToJson(this);
}

@JsonSerializable()
class WarrantyRequestResponse {
  final int id;
  final int vehicleId;
  final String plateNumber;
  final String chassisNumber;
  final String? contractCode;
  final String? warrantyExpiryDate;
  final int customerId;
  final String customerName;
  final String issueDescription;
  final String status;
  final String? scheduledDate;
  final int? technicianId;
  final String? technicianName;
  final String? result;
  @JsonKey(defaultValue: [])
  final List<String> imageUrls;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<WarrantyLogResponse> logs;

  const WarrantyRequestResponse({
    required this.id,
    required this.vehicleId,
    required this.plateNumber,
    required this.chassisNumber,
    this.contractCode,
    this.warrantyExpiryDate,
    required this.customerId,
    required this.customerName,
    required this.issueDescription,
    required this.status,
    this.scheduledDate,
    this.technicianId,
    this.technicianName,
    this.result,
    this.imageUrls = const [],
    required this.createdAt,
    required this.updatedAt,
    required this.logs,
  });

  factory WarrantyRequestResponse.fromJson(Map<String, dynamic> json) =>
      _$WarrantyRequestResponseFromJson(json);
  Map<String, dynamic> toJson() => _$WarrantyRequestResponseToJson(this);
}
