import '../entities/order.dart';

abstract class OrderRepository {
  Future<List<Order>> getOrders({int page = 0, int size = 10, String? status});
  Future<Order> getOrderById(String id);
  Future<Order> createQuotation({
    required String productId,
    required String truckType,
    required double truckLength,
    required String requirements,
    String? note,
  });
}
