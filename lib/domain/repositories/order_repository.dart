import '../entities/order.dart';
import '../../data/models/request/quotation_request.dart';

abstract class OrderRepository {
  Future<List<Order>> getOrders({int page = 0, int size = 10, String? status});
  Future<Order> getOrderById(String id);
  Future<Order> createQuotation(QuotationRequest request);
}
