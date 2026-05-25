enum OrderStatus { pending, confirmed, inProduction, completed, cancelled }

class Order {
  final String id;
  final String orderCode;
  final String productId;
  final String productName;
  final String? customerName;
  final String? customerPhone;
  final OrderStatus status;
  final String productionStatus;
  final double totalAmount;
  final double depositAmount;
  final String? note;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? estimatedDate;
  final String? assignedStaffName;

  const Order({
    required this.id,
    required this.orderCode,
    required this.productId,
    required this.productName,
    this.customerName,
    this.customerPhone,
    required this.status,
    this.productionStatus = '',
    required this.totalAmount,
    this.depositAmount = 0,
    this.note,
    required this.createdAt,
    this.updatedAt,
    this.estimatedDate,
    this.assignedStaffName,
  });
}
