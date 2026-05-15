// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OrderStatusLogResponse _$OrderStatusLogResponseFromJson(
  Map<String, dynamic> json,
) => OrderStatusLogResponse(
  id: (json['id'] as num).toInt(),
  status: json['status'] as String,
  note: json['note'] as String?,
  createdAt: DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$OrderStatusLogResponseToJson(
  OrderStatusLogResponse instance,
) => <String, dynamic>{
  'id': instance.id,
  'status': instance.status,
  'note': instance.note,
  'createdAt': instance.createdAt.toIso8601String(),
};

QuotationResponse _$QuotationResponseFromJson(Map<String, dynamic> json) =>
    QuotationResponse(
      id: (json['id'] as num).toInt(),
      customerId: (json['customerId'] as num).toInt(),
      customerName: json['customerName'] as String?,
      customerPhone: json['customerPhone'] as String?,
      product: json['product'] == null
          ? null
          : ProductResponse.fromJson(json['product'] as Map<String, dynamic>),
      productName: json['productName'] as String?,
      weightRange: json['weightRange'] as String? ?? '',
      cargoType: json['cargoType'] as String? ?? '',
      note: json['note'] as String?,
      vehicleBrand: json['vehicleBrand'] as String?,
      bodyType: json['bodyType'] as String?,
      bodySize: json['bodySize'] as String?,
      lengthCm: (json['lengthCm'] as num?)?.toDouble(),
      widthCm: (json['widthCm'] as num?)?.toDouble(),
      heightCm: (json['heightCm'] as num?)?.toDouble(),
      options:
          (json['options'] as List<dynamic>?)?.map((e) => e as String).toList(),
      status: json['status'] as String,
      contacted: json['contacted'] as bool? ?? false,
      contactedByName: json['contactedByName'] as String?,
      contactedAt: json['contactedAt'] == null
          ? null
          : DateTime.parse(json['contactedAt'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$QuotationResponseToJson(QuotationResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'customerId': instance.customerId,
      'customerName': instance.customerName,
      'customerPhone': instance.customerPhone,
      'product': instance.product,
      'productName': instance.productName,
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
      'status': instance.status,
      'contacted': instance.contacted,
      'contactedByName': instance.contactedByName,
      'contactedAt': instance.contactedAt?.toIso8601String(),
      'createdAt': instance.createdAt.toIso8601String(),
    };

OrderResponse _$OrderResponseFromJson(Map<String, dynamic> json) =>
    OrderResponse(
      id: (json['id'] as num).toInt(),
      quotationId: (json['quotationId'] as num?)?.toInt(),
      totalAmount: (json['totalAmount'] as num).toDouble(),
      depositAmount: (json['depositAmount'] as num).toDouble(),
      status: json['status'] as String,
      productionStatus: json['productionStatus'] as String,
      orderCode: json['orderCode'] as String?,
      productName: json['productName'] as String?,
      note: json['note'] as String?,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      estimatedDate: json['estimatedDate'] == null
          ? null
          : DateTime.parse(json['estimatedDate'] as String),
      statusLogs: (json['statusLogs'] as List<dynamic>? ?? [])
          .map(
            (e) => OrderStatusLogResponse.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
    );

Map<String, dynamic> _$OrderResponseToJson(OrderResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'quotationId': instance.quotationId,
      'totalAmount': instance.totalAmount,
      'depositAmount': instance.depositAmount,
      'status': instance.status,
      'productionStatus': instance.productionStatus,
      'orderCode': instance.orderCode,
      'productName': instance.productName,
      'note': instance.note,
      'createdAt': instance.createdAt?.toIso8601String(),
      'estimatedDate': instance.estimatedDate?.toIso8601String(),
      'statusLogs': instance.statusLogs,
    };
