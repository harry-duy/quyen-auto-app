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
    id:               r.id.toString(),
    orderCode:        r.orderCode ?? '#ORD-${r.id}',
    productId:        r.quotationId.toString(),
    productName:      r.productName ?? 'Đơn hàng #${r.id}',
    status:           _parseStatus(r.status),
    totalAmount:      r.totalAmount,
    note:             r.note,
    createdAt:        r.createdAt ?? DateTime.now(),
    updatedAt:        r.estimatedDate,
  );

  Order _fromQuotation(QuotationResponse q) => Order(
    id:          q.id.toString(),
    orderCode:   '#QUO-${q.id}',
    productId:   q.id.toString(),
    productName: q.productName ?? q.product?.name ?? 'Báo giá #${q.id}',
    status:      OrderStatus.pending,
    totalAmount: 0,
    note:        q.note,
    createdAt:   q.createdAt,
    updatedAt:   null,
  );

  @override
  Future<List<Order>> getOrders({int page = 0, int size = 10, String? status}) async {
    final res = await _api.get<List<Order>>(
      ApiConstants.myOrders,
      queryParams: {
        'page': page, 'size': size,
        if (status != null) 'status': status,
      },
      fromData: (json) => (json as List)
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
    required String vehicleBrand,
    required String bodyType,
    required String bodySize,
    double? lengthCm,
    double? widthCm,
    double? heightCm,
    List<String>? options,
    String? note,
  }) async {
    final req = QuotationRequest(
      productId:    int.parse(productId),
      weightRange:  bodySize,
      cargoType:    bodyType,
      vehicleBrand: vehicleBrand,
      bodyType:     bodyType,
      bodySize:     bodySize,
      lengthCm:     lengthCm,
      widthCm:      widthCm,
      heightCm:     heightCm,
      options:      options,
      note:         note,
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
