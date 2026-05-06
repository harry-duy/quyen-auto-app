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
    );

Map<String, dynamic> _$QuotationRequestToJson(QuotationRequest instance) =>
    <String, dynamic>{
      'productId': instance.productId,
      'weightRange': instance.weightRange,
      'cargoType': instance.cargoType,
      'note': instance.note,
    };
