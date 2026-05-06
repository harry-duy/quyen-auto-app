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
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$WarrantyLogResponseToJson(
  WarrantyLogResponse instance,
) => <String, dynamic>{
  'id': instance.id,
  'action': instance.action,
  'note': instance.note,
  'createdAt': instance.createdAt.toIso8601String(),
};

VehicleResponse _$VehicleResponseFromJson(Map<String, dynamic> json) =>
    VehicleResponse(
      id: (json['id'] as num).toInt(),
      plateNumber: json['plateNumber'] as String,
      chassisNumber: json['chassisNumber'] as String,
      purchaseDate: DateTime.parse(json['purchaseDate'] as String),
      product: json['product'] == null
          ? null
          : ProductResponse.fromJson(json['product'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$VehicleResponseToJson(VehicleResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'plateNumber': instance.plateNumber,
      'chassisNumber': instance.chassisNumber,
      'purchaseDate': instance.purchaseDate.toIso8601String(),
      'product': instance.product,
    };

WarrantyRequestResponse _$WarrantyRequestResponseFromJson(
  Map<String, dynamic> json,
) => WarrantyRequestResponse(
  id: (json['id'] as num).toInt(),
  vehicle: VehicleResponse.fromJson(json['vehicle'] as Map<String, dynamic>),
  issueDescription: json['issueDescription'] as String,
  status: json['status'] as String,
  scheduledDate: json['scheduledDate'] == null
      ? null
      : DateTime.parse(json['scheduledDate'] as String),
  logs: (json['logs'] as List<dynamic>)
      .map((e) => WarrantyLogResponse.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$WarrantyRequestResponseToJson(
  WarrantyRequestResponse instance,
) => <String, dynamic>{
  'id': instance.id,
  'vehicle': instance.vehicle,
  'issueDescription': instance.issueDescription,
  'status': instance.status,
  'scheduledDate': instance.scheduledDate?.toIso8601String(),
  'logs': instance.logs,
};
