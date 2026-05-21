// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'warranty_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WarrantyLogResponse _$WarrantyLogResponseFromJson(Map<String, dynamic> json) =>
    WarrantyLogResponse(
      id: (json['id'] as num).toInt(),
      action: json['action'] as String,
      note: json['note'] as String?,
      performedBy: json['performedBy'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$WarrantyLogResponseToJson(
  WarrantyLogResponse instance,
) => <String, dynamic>{
  'id': instance.id,
  'action': instance.action,
  'note': instance.note,
  'performedBy': instance.performedBy,
  'createdAt': instance.createdAt.toIso8601String(),
};

VehicleResponse _$VehicleResponseFromJson(Map<String, dynamic> json) =>
    VehicleResponse(
      id: (json['id'] as num).toInt(),
      ownerId: (json['ownerId'] as num).toInt(),
      ownerName: json['ownerName'] as String,
      productId: (json['productId'] as num?)?.toInt(),
      productName: json['productName'] as String?,
      plateNumber: json['plateNumber'] as String,
      chassisNumber: json['chassisNumber'] as String,
      purchaseDate: json['purchaseDate'] as String,
      contractCode: json['contractCode'] as String?,
      warrantyExpiryDate: json['warrantyExpiryDate'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$VehicleResponseToJson(VehicleResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'ownerId': instance.ownerId,
      'ownerName': instance.ownerName,
      'productId': instance.productId,
      'productName': instance.productName,
      'plateNumber': instance.plateNumber,
      'chassisNumber': instance.chassisNumber,
      'purchaseDate': instance.purchaseDate,
      'contractCode': instance.contractCode,
      'warrantyExpiryDate': instance.warrantyExpiryDate,
      'createdAt': instance.createdAt.toIso8601String(),
    };

WarrantyRequestResponse _$WarrantyRequestResponseFromJson(
  Map<String, dynamic> json,
) => WarrantyRequestResponse(
  id: (json['id'] as num).toInt(),
  vehicleId: (json['vehicleId'] as num).toInt(),
  plateNumber: json['plateNumber'] as String,
  chassisNumber: json['chassisNumber'] as String,
  contractCode: json['contractCode'] as String?,
  warrantyExpiryDate: json['warrantyExpiryDate'] as String?,
  customerId: (json['customerId'] as num).toInt(),
  customerName: json['customerName'] as String,
  issueDescription: json['issueDescription'] as String,
  status: json['status'] as String,
  scheduledDate: json['scheduledDate'] as String?,
  technicianId: (json['technicianId'] as num?)?.toInt(),
  technicianName: json['technicianName'] as String?,
  result: json['result'] as String?,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
  logs: (json['logs'] as List<dynamic>?)
          ?.map((e) => WarrantyLogResponse.fromJson(e as Map<String, dynamic>))
          .toList() ??
      [],
);

Map<String, dynamic> _$WarrantyRequestResponseToJson(
  WarrantyRequestResponse instance,
) => <String, dynamic>{
  'id': instance.id,
  'vehicleId': instance.vehicleId,
  'plateNumber': instance.plateNumber,
  'chassisNumber': instance.chassisNumber,
  'contractCode': instance.contractCode,
  'warrantyExpiryDate': instance.warrantyExpiryDate,
  'customerId': instance.customerId,
  'customerName': instance.customerName,
  'issueDescription': instance.issueDescription,
  'status': instance.status,
  'scheduledDate': instance.scheduledDate,
  'technicianId': instance.technicianId,
  'technicianName': instance.technicianName,
  'result': instance.result,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
  'logs': instance.logs,
};
