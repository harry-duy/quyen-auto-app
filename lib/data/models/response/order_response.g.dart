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
      product: json['product'] == null
          ? null
          : ProductResponse.fromJson(json['product'] as Map<String, dynamic>),
      weightRange: json['weightRange'] as String,
      cargoType: json['cargoType'] as String,
      note: json['note'] as String?,
      status: json['status'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$QuotationResponseToJson(QuotationResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'customerId': instance.customerId,
      'product': instance.product,
      'weightRange': instance.weightRange,
      'cargoType': instance.cargoType,
      'note': instance.note,
      'status': instance.status,
      'createdAt': instance.createdAt.toIso8601String(),
    };

OrderResponse _$OrderResponseFromJson(Map<String, dynamic> json) =>
    OrderResponse(
      id: (json['id'] as num).toInt(),
      quotationId: (json['quotationId'] as num?)?.toInt(),
      customerId: (json['customerId'] as num?)?.toInt(),
      customerName: json['customerName'] as String?,
      customerPhone: json['customerPhone'] as String?,
      productId: (json['productId'] as num?)?.toInt(),
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
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
      estimatedDate: json['estimatedDate'] == null
          ? null
          : DateTime.parse(json['estimatedDate'] as String),
      assignedStaffId: (json['assignedStaffId'] as num?)?.toInt(),
      assignedStaffName: json['assignedStaffName'] as String?,
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
      'customerId': instance.customerId,
      'customerName': instance.customerName,
      'customerPhone': instance.customerPhone,
      'productId': instance.productId,
      'totalAmount': instance.totalAmount,
      'depositAmount': instance.depositAmount,
      'status': instance.status,
      'productionStatus': instance.productionStatus,
      'orderCode': instance.orderCode,
      'productName': instance.productName,
      'note': instance.note,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
      'estimatedDate': instance.estimatedDate?.toIso8601String(),
      'assignedStaffId': instance.assignedStaffId,
      'assignedStaffName': instance.assignedStaffName,
      'statusLogs': instance.statusLogs,
    };
