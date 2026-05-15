import 'package:json_annotation/json_annotation.dart';
import 'product_response.dart';
part 'order_response.g.dart';

@JsonSerializable()
class OrderStatusLogResponse {
  final int      id;
  final String   status;
  final String?  note;
  final DateTime createdAt;

  const OrderStatusLogResponse({
    required this.id,
    required this.status,
    this.note,
    required this.createdAt,
  });

  factory OrderStatusLogResponse.fromJson(Map<String, dynamic> json) =>
      _$OrderStatusLogResponseFromJson(json);
  Map<String, dynamic> toJson() => _$OrderStatusLogResponseToJson(this);
}

@JsonSerializable()
class QuotationResponse {
  final int              id;
  final int              customerId;
  final String?          customerName;
  final String?          customerPhone;
  final ProductResponse? product;
  final String?          productName;
  final String           weightRange;
  final String           cargoType;
  final String?          note;
  final String?          vehicleBrand;
  final String?          bodyType;
  final String?          bodySize;
  final double?          lengthCm;
  final double?          widthCm;
  final double?          heightCm;
  final List<String>?    options;
  final String           status;
  final bool             contacted;
  final String?          contactedByName;
  final DateTime?        contactedAt;
  final DateTime         createdAt;

  const QuotationResponse({
    required this.id,
    required this.customerId,
    this.customerName,
    this.customerPhone,
    this.product,
    this.productName,
    required this.weightRange,
    required this.cargoType,
    this.note,
    this.vehicleBrand,
    this.bodyType,
    this.bodySize,
    this.lengthCm,
    this.widthCm,
    this.heightCm,
    this.options,
    required this.status,
    this.contacted = false,
    this.contactedByName,
    this.contactedAt,
    required this.createdAt,
  });

  factory QuotationResponse.fromJson(Map<String, dynamic> json) =>
      _$QuotationResponseFromJson(json);
  Map<String, dynamic> toJson() => _$QuotationResponseToJson(this);
}

@JsonSerializable()
class OrderResponse {
  final int                      id;
  final int?                     quotationId;
  final double                   totalAmount;
  final double                   depositAmount;
  final String                   status;
  final String                   productionStatus;
  final String?                  orderCode;
  final String?                  productName;
  final String?                  note;
  final DateTime?                createdAt;
  final DateTime?                estimatedDate;
  final List<OrderStatusLogResponse> statusLogs;

  const OrderResponse({
    required this.id,
    this.quotationId,
    required this.totalAmount,
    required this.depositAmount,
    required this.status,
    required this.productionStatus,
    this.orderCode,
    this.productName,
    this.note,
    this.createdAt,
    this.estimatedDate,
    required this.statusLogs,
  });

  factory OrderResponse.fromJson(Map<String, dynamic> json) =>
      _$OrderResponseFromJson(json);
  Map<String, dynamic> toJson() => _$OrderResponseToJson(this);
}
