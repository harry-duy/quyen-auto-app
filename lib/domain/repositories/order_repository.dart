import '../entities/order.dart';

abstract class OrderRepository {
  Future<List<Order>> getOrders({int page = 0, int size = 10, String? status});
  Future<Order> getOrderById(String id);
  Future<Order> createQuotation({
    required String productId,
    required String vehicleBrand,
    required String bodyType,
    required String bodySize,
    double? lengthCm,
    double? widthCm,
    double? heightCm,
    List<String>? options,
    String? note,
  });
}
