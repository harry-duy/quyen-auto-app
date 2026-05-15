import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/api_constants.dart';
import '../../data/models/response/dealer_response.dart';
import '../../data/models/response/order_response.dart';
import '../../data/models/response/warranty_response.dart';
import '../../data/services/api_service.dart';
import '../../domain/entities/order.dart';
import 'service_providers.dart';

// ─── Staff Tab Index ─────────────────────────────────────────────────────────

final staffTabIndexProvider = StateProvider<int>((ref) => 0);

// ─── Dashboard ───────────────────────────────────────────────────────────────

final staffDashboardProvider =
    FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  final api = ref.watch(apiServiceProvider);
  final res = await api.get<Map<String, dynamic>>(
    ApiConstants.staffDashboard,
    fromData: (json) => json as Map<String, dynamic>,
  );
  return res.data ?? {};
});

// ─── Staff Order Management ──────────────────────────────────────────────────

final staffOrderStatusFilter = StateProvider<String?>((ref) => null);

final staffOrderListProvider =
    FutureProvider.autoDispose<List<Order>>((ref) async {
  final api = ref.watch(apiServiceProvider);
  final status = ref.watch(staffOrderStatusFilter);
  final res = await api.get<List<Order>>(
    ApiConstants.staffOrders,
    queryParams: {
      'page': 0,
      'size': 50,
      if (status != null) 'status': status,
    },
    fromData: (json) => _items(json)
        .map((e) => _orderFromJson(e as Map<String, dynamic>))
        .toList(),
  );
  return res.data ?? [];
});

final staffOrderDetailProvider =
    FutureProvider.autoDispose.family<Order, String>((ref, id) async {
  final api = ref.watch(apiServiceProvider);
  final res = await api.get<Order>(
    ApiConstants.resolve(ApiConstants.staffOrderDetail, {'id': id}),
    fromData: (json) => _orderFromJson(json as Map<String, dynamic>),
  );
  return res.data!;
});

// ─── Quotation Management ────────────────────────────────────────────────────

final staffQuotationListProvider =
    FutureProvider.autoDispose<List<QuotationResponse>>((ref) async {
  final api = ref.watch(apiServiceProvider);
  final res = await api.get<List<QuotationResponse>>(
    ApiConstants.staffQuotations,
    queryParams: {'status': 'PENDING'},
    fromData: (json) => _items(json)
        .map((e) => QuotationResponse.fromJson(e as Map<String, dynamic>))
        .toList(),
  );
  return res.data ?? [];
});

final staffPendingQuoteCountProvider =
    FutureProvider.autoDispose<int>((ref) async {
  final api = ref.watch(apiServiceProvider);
  final res = await api.get<int>(
    ApiConstants.staffPendingQuoteCount,
    fromData: (json) => (json as num).toInt(),
  );
  return res.data ?? 0;
});

// ─── Warranty Management ─────────────────────────────────────────────────────

final staffWarrantyListProvider =
    FutureProvider.autoDispose<List<WarrantyRequestResponse>>((ref) async {
  final api = ref.watch(apiServiceProvider);
  final res = await api.get<List<WarrantyRequestResponse>>(
    ApiConstants.staffWarrantyList,
    fromData: (json) => _items(json)
        .map((e) =>
            WarrantyRequestResponse.fromJson(e as Map<String, dynamic>))
        .toList(),
  );
  return res.data ?? [];
});

// ─── Dealer List ─────────────────────────────────────────────────────────────

final dealerListProvider =
    FutureProvider.autoDispose<List<DealerResponse>>((ref) async {
  final api = ref.watch(apiServiceProvider);
  final res = await api.get<List<DealerResponse>>(
    ApiConstants.dealerList,
    fromData: (json) => (json as List)
        .map((e) => DealerResponse.fromJson(e as Map<String, dynamic>))
        .toList(),
  );
  return res.data ?? [];
});

// ─── Staff Actions ───────────────────────────────────────────────────────────

class StaffActionsNotifier extends Notifier<void> {
  @override
  void build() {}

  ApiService get _api => ref.read(apiServiceProvider);

  Future<void> updateOrderStatus(
      String orderId, String newStatus, String? note) async {
    await _api.patch(
      ApiConstants.resolve(ApiConstants.staffUpdateStatus, {'id': orderId}),
      data: {'status': newStatus, if (note != null) 'note': note},
    );
    ref.invalidate(staffOrderListProvider);
    ref.invalidate(staffOrderDetailProvider(orderId));
    ref.invalidate(staffDashboardProvider);
  }

  Future<void> approveQuotation(
      String quotationId, double price, String? note) async {
    await _api.patch(
      ApiConstants.resolve(
          ApiConstants.staffApproveQuote, {'id': quotationId}),
      data: {'quotedPrice': price, if (note != null) 'staffNote': note},
    );
    ref.invalidate(staffQuotationListProvider);
    ref.invalidate(staffPendingQuoteCountProvider);
    ref.invalidate(staffDashboardProvider);
  }

  Future<void> markQuotationContacted(String quotationId) async {
    await _api.put(
      ApiConstants.resolve(
          ApiConstants.staffMarkContacted, {'id': quotationId}),
    );
    ref.invalidate(staffQuotationListProvider);
    ref.invalidate(staffPendingQuoteCountProvider);
    ref.invalidate(staffDashboardProvider);
  }

  Future<void> createCustomerAccount({
    required String fullName,
    required String phone,
    required String password,
    String? email,
  }) async {
    await _api.post(
      ApiConstants.staffCreateCustomer,
      data: {
        'fullName': fullName,
        'phone': phone,
        'password': password,
        if (email != null && email.isNotEmpty) 'email': email,
      },
    );
  }

  Future<void> assignWarrantyTechnician(
      String warrantyId, String technicianId) async {
    await _api.patch(
      ApiConstants.resolve(
          ApiConstants.staffWarrantyAssign, {'id': warrantyId}),
      data: {'technicianId': int.parse(technicianId)},
    );
    ref.invalidate(staffWarrantyListProvider);
  }

  Future<void> updateWarrantyResult(
      String warrantyId, String result, String? note) async {
    await _api.patch(
      ApiConstants.resolve(
          ApiConstants.staffWarrantyUpdate, {'id': warrantyId}),
      data: {'status': result, 'result': result, if (note != null) 'note': note},
    );
    ref.invalidate(staffWarrantyListProvider);
    ref.invalidate(staffDashboardProvider);
  }

  /// Duyet yeu cau huy don hang cua khach hang => CANCELLED.
  Future<void> approveCancel(String orderId, {String? note}) async {
    final url = ApiConstants.resolve(ApiConstants.staffApproveCancel, {'id': orderId});
    await _api.patch(
      note != null ? '$url?note=${Uri.encodeComponent(note)}' : url,
      data: {},
    );
    ref.invalidate(staffOrderListProvider);
    ref.invalidate(staffOrderDetailProvider(orderId));
    ref.invalidate(staffDashboardProvider);
  }

  /// Tu choi yeu cau huy don hang => ve lai PENDING.
  Future<void> rejectCancel(String orderId, {String? note}) async {
    final url = ApiConstants.resolve(ApiConstants.staffRejectCancel, {'id': orderId});
    await _api.patch(
      note != null ? '$url?note=${Uri.encodeComponent(note)}' : url,
      data: {},
    );
    ref.invalidate(staffOrderListProvider);
    ref.invalidate(staffOrderDetailProvider(orderId));
    ref.invalidate(staffDashboardProvider);
  }
}

final staffActionsProvider =
    NotifierProvider<StaffActionsNotifier, void>(StaffActionsNotifier.new);

// ─── Helpers ─────────────────────────────────────────────────────────────────

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

Order _orderFromJson(Map<String, dynamic> j) {
  final r = OrderResponse.fromJson(j);
  return Order(
    id: r.id.toString(),
    orderCode: r.orderCode ?? '#ORD-${r.id}',
    productId: r.quotationId?.toString() ?? '',
    productName: r.productName ?? 'Đơn hàng #${r.id}',
    status: _parseStatus(r.status),
    totalAmount: r.totalAmount,
    note: r.note,
    createdAt: r.createdAt ?? DateTime.now(),
    updatedAt: r.estimatedDate,
  );
}
