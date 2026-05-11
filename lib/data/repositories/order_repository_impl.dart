import '../../domain/entities/order.dart';
import '../../domain/repositories/order_repository.dart';
import '../services/api_service.dart';
import '../models/request/quotation_request.dart';
import '../models/response/order_response.dart';
import '../../core/constants/api_constants.dart';

class OrderRepositoryImpl implements OrderRepository {
  final ApiService _api;

  OrderRepositoryImpl(this._api);

  List<dynamic> _items(dynamic json) {
    if (json is Map<String, dynamic> && json['content'] is List) {
      return json['content'] as List;
    }
    return json as List;
  }

  OrderStatus _parseStatus(String s) => OrderStatus.values.firstWhere(
    (e) => e.name.toLowerCase() == s.replaceAll('_', '').toLowerCase(),
    orElse: () => OrderStatus.pending,
  );

  Order _fromResponse(OrderResponse r) => Order(
    id:               r.id.toString(),
    orderCode:        r.orderCode ?? '#ORD-${r.id}',
    productId:        r.quotationId?.toString() ?? '',
    productName:      r.productName ?? 'Đơn hàng #${r.id}',
    status:           _parseStatus(r.status),
    totalAmount:      r.totalAmount,
    note:             r.note,
    createdAt:        r.createdAt ?? DateTime.now(),
    updatedAt:        r.estimatedDate,
  );

  Order _fromQuotation(QuotationResponse r) => Order(
    id: r.id.toString(),
    orderCode: '#QUOTE-${r.id}',
    productId: r.product?.id.toString() ?? '',
    productName: r.product?.name ?? 'Yeu cau bao gia #${r.id}',
    status: _parseStatus(r.status),
    totalAmount: 0,
    note: r.note,
    createdAt: r.createdAt,
    updatedAt: null,
  );

  @override
  Future<List<Order>> getOrders({int page = 0, int size = 10, String? status}) async {
    final res = await _api.get<List<Order>>(
      ApiConstants.myOrders,
      queryParams: {
        'page': page, 'size': size,
        if (status != null) 'status': status,
      },
      fromData: (json) => _items(json)
          .map((e) => _fromResponse(OrderResponse.fromJson(e as Map<String, dynamic>)))
          .toList(),
    );
    return res.data ?? [];
  }

  @override
  Future<Order> getOrderById(String id) async {
    final res = await _api.get<Order>(
      ApiConstants.resolve(ApiConstants.orderDetail, {'id': id}),
      fromData: (json) => _fromResponse(
        OrderResponse.fromJson(json as Map<String, dynamic>),
      ),
    );
    return res.data!;
  }

  @override
  Future<Order> createQuotation({
    required String productId,
    required String truckType,
    required double truckLength,
    required String requirements,
    String? note,
  }) async {
    final req = QuotationRequest(
      productId:   int.parse(productId),
      weightRange: '$truckLength tấn',
      cargoType:   requirements,
      note:        note,
    );
    final res = await _api.post<Order>(
      ApiConstants.createQuotation,
      data: req.toJson(),
      fromData: (json) => _fromQuotation(
        QuotationResponse.fromJson(json as Map<String, dynamic>),
      ),
    );
    return res.data!;
  }
}
