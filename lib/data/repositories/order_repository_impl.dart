import '../../domain/entities/order.dart';
import '../../domain/repositories/order_repository.dart';
import '../services/api_service.dart';
import '../models/request/quotation_request.dart';
import '../models/response/order_response.dart';
import '../../core/constants/api_constants.dart';

class OrderRepositoryImpl implements OrderRepository {
  final ApiService _api;

  OrderRepositoryImpl(this._api);

  OrderStatus _parseStatus(String s) => OrderStatus.values.firstWhere(
    (e) => e.name.toLowerCase() == s.replaceAll('_', '').toLowerCase(),
    orElse: () => OrderStatus.pending,
  );

  Order _fromResponse(OrderResponse r) => Order(
    id: r.id.toString(),
    orderCode: r.orderCode ?? '#ORD-${r.id}',
    productId: (r.productId ?? r.quotationId ?? '').toString(),
    productName: r.productName ?? 'Đơn hàng #${r.id}',
    customerName: r.customerName,
    customerPhone: r.customerPhone,
    status: _parseStatus(r.status),
    productionStatus: r.productionStatus,
    totalAmount: r.totalAmount,
    depositAmount: r.depositAmount,
    note: r.note,
    createdAt: r.createdAt ?? DateTime.now(),
    updatedAt: r.updatedAt,
    estimatedDate: r.estimatedDate,
    assignedStaffName: r.assignedStaffName,
  );

  @override
  Future<List<Order>> getOrders({
    int page = 0,
    int size = 10,
    String? status,
  }) async {
    final res = await _api.get<List<Order>>(
      ApiConstants.myOrders,
      queryParams: {'page': page, 'size': size, 'status': ?status},
      fromData: (json) {
        final list = json is List
            ? json
            : (json as Map<String, dynamic>)['content'] as List<dynamic>? ?? [];
        return list
            .map(
              (e) => _fromResponse(
                OrderResponse.fromJson(e as Map<String, dynamic>),
              ),
            )
            .toList();
      },
    );
    return res.data ?? [];
  }

  @override
  Future<Order> getOrderById(String id) async {
    final res = await _api.get<Order>(
      ApiConstants.resolve(ApiConstants.orderDetail, {'id': id}),
      fromData: (json) =>
          _fromResponse(OrderResponse.fromJson(json as Map<String, dynamic>)),
    );
    return res.data!;
  }

  @override
  Future<Order> createQuotation(QuotationRequest request) async {
    // Backend POST /quotations trả về QuotationResponse, không phải OrderResponse
    final res = await _api.post<Order>(
      ApiConstants.createQuotation,
      data: request.toJson(),
      fromData: (json) {
        final j = json as Map<String, dynamic>;
        return Order(
          id: j['id'].toString(),
          orderCode: 'QT-${j['id']}',
          productId: (j['productId'] ?? 0).toString(),
          productName: j['productName'] as String? ?? 'Yêu cầu báo giá',
          status: OrderStatus.pending,
          totalAmount: 0,
          note: j['note'] as String?,
          createdAt: DateTime.parse(j['createdAt'] as String),
        );
      },
    );
    return res.data!;
  }
}
