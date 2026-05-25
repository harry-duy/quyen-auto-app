import 'package:json_annotation/json_annotation.dart';
import 'product_response.dart';
part 'order_response.g.dart';

@JsonSerializable()
class OrderStatusLogResponse {
  final int id;
  final String status;
  final String? note;
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
  final int id;
  final int customerId;
  final ProductResponse? product;
  final String weightRange;
  final String cargoType;
  final String? note;
  final String status;
  final DateTime createdAt;

  const QuotationResponse({
    required this.id,
    required this.customerId,
    this.product,
    required this.weightRange,
    required this.cargoType,
    this.note,
    required this.status,
    required this.createdAt,
  });

  factory QuotationResponse.fromJson(Map<String, dynamic> json) =>
      _$QuotationResponseFromJson(json);
  Map<String, dynamic> toJson() => _$QuotationResponseToJson(this);
}

@JsonSerializable()
class OrderResponse {
  final int id;
  final int? quotationId;
  final int? customerId;
  final String? customerName;
  final String? customerPhone;
  final int? productId;
  final double totalAmount;
  final double depositAmount;
  final String status;
  final String productionStatus;
  final String? orderCode;
  final String? productName;
  final String? note;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? estimatedDate;
  final int? assignedStaffId;
  final String? assignedStaffName;
  final List<OrderStatusLogResponse> statusLogs;

  const OrderResponse({
    required this.id,
    this.quotationId,
    this.customerId,
    this.customerName,
    this.customerPhone,
    this.productId,
    required this.totalAmount,
    required this.depositAmount,
    required this.status,
    required this.productionStatus,
    this.orderCode,
    this.productName,
    this.note,
    this.createdAt,
    this.updatedAt,
    this.estimatedDate,
    this.assignedStaffId,
    this.assignedStaffName,
    this.statusLogs = const [],
  });

  factory OrderResponse.fromJson(Map<String, dynamic> json) =>
      _$OrderResponseFromJson(json);
  Map<String, dynamic> toJson() => _$OrderResponseToJson(this);
}
