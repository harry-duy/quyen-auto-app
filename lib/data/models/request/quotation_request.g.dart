// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quotation_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

QuotationRequest _$QuotationRequestFromJson(Map<String, dynamic> json) =>
    QuotationRequest(
      productId: (json['productId'] as num).toInt(),
      weightRange: json['weightRange'] as String,
      cargoType: json['cargoType'] as String,
      note: json['note'] as String?,
      vehicleBrand: json['vehicleBrand'] as String?,
      bodyType: json['bodyType'] as String?,
      bodySize: json['bodySize'] as String?,
      lengthCm: (json['lengthCm'] as num?)?.toDouble(),
      widthCm: (json['widthCm'] as num?)?.toDouble(),
      heightCm: (json['heightCm'] as num?)?.toDouble(),
      options:
          (json['options'] as List<dynamic>?)?.map((e) => e as String).toList(),
    );

Map<String, dynamic> _$QuotationRequestToJson(QuotationRequest instance) =>
    <String, dynamic>{
      'productId': instance.productId,
      'weightRange': instance.weightRange,
      'cargoType': instance.cargoType,
      'note': instance.note,
      'vehicleBrand': instance.vehicleBrand,
      'bodyType': instance.bodyType,
      'bodySize': instance.bodySize,
      'lengthCm': instance.lengthCm,
      'widthCm': instance.widthCm,
      'heightCm': instance.heightCm,
      'options': instance.options,
    };
