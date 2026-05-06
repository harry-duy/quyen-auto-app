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
  final ProductResponse? product;
  final String           weightRange;
  final String           cargoType;
  final String?          note;
  final String           status;
  final DateTime         createdAt;

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
  final int                      id;
  final int                      quotationId;
  final double                   totalAmount;
  final double                   depositAmount;
  final String                   status;
  final String                   productionStatus;
  final DateTime?                estimatedDate;
  final List<OrderStatusLogResponse> statusLogs;

  const OrderResponse({
    required this.id,
    required this.quotationId,
    required this.totalAmount,
    required this.depositAmount,
    required this.status,
    required this.productionStatus,
    this.estimatedDate,
    required this.statusLogs,
  });

  factory OrderResponse.fromJson(Map<String, dynamic> json) =>
      _$OrderResponseFromJson(json);
  Map<String, dynamic> toJson() => _$OrderResponseToJson(this);
}
