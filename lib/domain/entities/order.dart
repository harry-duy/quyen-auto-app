// TODO: Pure domain entity — no JSON/framework dependencies

enum OrderStatus { pending, confirmed, inProduction, completed, cancelled }

class Order {
  final String id;
  final String orderCode;
  final String productId;
  final String productName;
  final OrderStatus status;
  final double totalAmount;
  final String? note;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const Order({
    required this.id,
    required this.orderCode,
    required this.productId,
    required this.productName,
    required this.status,
    required this.totalAmount,
    this.note,
    required this.createdAt,
    this.updatedAt,
  });
}
