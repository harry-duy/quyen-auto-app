import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/api_constants.dart';
import '../../data/models/response/dealer_response.dart';
import '../../data/models/response/order_response.dart';
import '../../data/models/response/quotation_response.dart';
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
      'status': ?status,
    },
    fromData: (json) => _toList(json)
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

final staffQuotationStatusFilter = StateProvider<String?>((ref) => null);

final staffQuotationListProvider =
    FutureProvider.autoDispose<List<StaffQuotationResponse>>((ref) async {
  final api = ref.watch(apiServiceProvider);
  final status = ref.watch(staffQuotationStatusFilter);
  final res = await api.get<List<StaffQuotationResponse>>(
    ApiConstants.staffQuotations,
    queryParams: {
      'page': 0,
      'size': 100,
      'status': ?status,
    },
    fromData: (json) => _parseQuotationPage(json),
  );
  return res.data ?? [];
});

final staffUncontactedCountProvider =
    FutureProvider.autoDispose<int>((ref) async {
  final api = ref.watch(apiServiceProvider);
  final res = await api.get<List<StaffQuotationResponse>>(
    ApiConstants.staffQuotations,
    queryParams: {'page': 0, 'size': 200, 'status': 'PENDING'},
    fromData: (json) => _parseQuotationPage(json),
  );
  return (res.data ?? []).where((q) => !q.isContacted).length;
});

// ─── Warranty Management ─────────────────────────────────────────────────────

final staffWarrantyListProvider =
    FutureProvider.autoDispose<List<WarrantyRequestResponse>>((ref) async {
  final api = ref.watch(apiServiceProvider);
  final res = await api.get<List<WarrantyRequestResponse>>(
    ApiConstants.staffWarrantyList,
    fromData: (json) => _toList(json)
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
    fromData: (json) => _toList(json)
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
    await _api.put(
      ApiConstants.resolve(ApiConstants.staffUpdateStatus, {'id': orderId}),
      data: {'status': newStatus, 'note': ?note},
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
      data: {
        'quotedPrice': price,
        'staffNote': ?note,
      },
    );
    ref.invalidate(staffQuotationListProvider);
    ref.invalidate(staffUncontactedCountProvider);
    ref.invalidate(staffDashboardProvider);
  }

  Future<void> markQuotationContacted(String quotationId) async {
    await _api.patch(
      ApiConstants.resolve(
          ApiConstants.staffQuotationContact, {'id': quotationId}),
    );
    ref.invalidate(staffQuotationListProvider);
    ref.invalidate(staffUncontactedCountProvider);
  }

  Future<void> assignWarrantyTechnician(
      String warrantyId, int technicianId, String? scheduledDate) async {
    await _api.patch(
      ApiConstants.resolve(
          ApiConstants.staffWarrantyAssign, {'id': warrantyId}),
      data: {
        'technicianId': technicianId,
        'scheduledDate': ?scheduledDate,
      },
    );
    ref.invalidate(staffWarrantyListProvider);
  }

  Future<void> updateWarrantyResult(
      String warrantyId, String status, String result, String? note) async {
    await _api.patch(
      ApiConstants.resolve(
          ApiConstants.staffWarrantyResult, {'id': warrantyId}),
      data: {'status': status, 'result': result, 'note': ?note},
    );
    ref.invalidate(staffWarrantyListProvider);
    ref.invalidate(staffDashboardProvider);
  }
}

final staffActionsProvider =
    NotifierProvider<StaffActionsNotifier, void>(StaffActionsNotifier.new);

// ─── Helpers ─────────────────────────────────────────────────────────────────

OrderStatus _parseStatus(String s) => OrderStatus.values.firstWhere(
      (e) => e.name.toLowerCase() == s.replaceAll('_', '').toLowerCase(),
      orElse: () => OrderStatus.pending,
    );

Order _orderFromJson(Map<String, dynamic> j) {
  final r = OrderResponse.fromJson(j);
  return Order(
    id: r.id.toString(),
    orderCode: r.orderCode ?? '#ORD-${r.id}',
    productId: r.quotationId.toString(),
    productName: r.productName ?? 'Đơn hàng #${r.id}',
    status: _parseStatus(r.status),
    totalAmount: r.totalAmount,
    note: r.note,
    createdAt: r.createdAt ?? DateTime.now(),
    updatedAt: r.estimatedDate,
  );
}

/// Extracts a flat list from either a plain JSON array, a Spring Boot
/// Page wrapper `{"content":[...]}`, or null (returns []).
List<dynamic> _toList(dynamic json) {
  if (json == null) return [];
  if (json is List) return json;
  return (json as Map<String, dynamic>)['content'] as List<dynamic>? ?? [];
}

/// Handles both a plain List and a PageResponse map with a 'content' field.
List<StaffQuotationResponse> _parseQuotationPage(dynamic json) {
  return _toList(json)
      .map((e) => StaffQuotationResponse.fromJson(e as Map<String, dynamic>))
      .toList();
}
