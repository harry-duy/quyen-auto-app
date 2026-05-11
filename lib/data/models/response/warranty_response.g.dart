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

VehicleInfo _$VehicleInfoFromJson(Map<String, dynamic> json) =>
    VehicleInfo(
      id: (json['id'] as num).toInt(),
      plateNumber: json['plateNumber'] as String,
      chassisNumber: json['chassisNumber'] as String,
      purchaseDate: json['purchaseDate'] as String?,
    );

Map<String, dynamic> _$VehicleInfoToJson(VehicleInfo instance) =>
    <String, dynamic>{
      'id': instance.id,
      'plateNumber': instance.plateNumber,
      'chassisNumber': instance.chassisNumber,
      'purchaseDate': instance.purchaseDate,
    };

WarrantyRequestResponse _$WarrantyRequestResponseFromJson(
  Map<String, dynamic> json,
) => WarrantyRequestResponse(
  id: (json['id'] as num).toInt(),
  vehicle: VehicleInfo.fromJson(json['vehicle'] as Map<String, dynamic>),
  issueDescription: json['issueDescription'] as String,
  status: json['status'] as String,
  scheduledDate: json['scheduledDate'] as String?,
  logs: (json['logs'] as List<dynamic>? ?? [])
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
  'scheduledDate': instance.scheduledDate,
  'logs': instance.logs,
};
