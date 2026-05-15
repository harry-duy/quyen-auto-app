import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/api_constants.dart';
import '../../domain/entities/order.dart';
import 'service_providers.dart';

// ─── Order Providers ─────────────────────────────────────────────────────────

final orderStatusFilterProvider = StateProvider<String?>((ref) => null);

final orderListProvider =
    FutureProvider.autoDispose<List<Order>>((ref) async {
  final repo = ref.watch(orderRepositoryProvider);
  final status = ref.watch(orderStatusFilterProvider);
  return repo.getOrders(page: 0, size: 50, status: status);
});

final orderDetailProvider =
    FutureProvider.autoDispose.family<Order, String>((ref, id) async {
  return ref.watch(orderRepositoryProvider).getOrderById(id);
});

// ─── Order WebSocket Stream Provider ─────────────────────────────────────────

final orderStatusStreamProvider =
    StreamProvider.autoDispose.family<String?, String>((ref, orderId) {
  final ws = ref.watch(webSocketServiceProvider);
  final controller = StreamController<String?>();

  if (ws.isConnected) {
    ws.subscribeOrder(orderId, (body) {
      try {
        final json = jsonDecode(body) as Map<String, dynamic>;
        final newStatus = json['status'] as String?;
        controller.add(newStatus);
      } catch (_) {
        controller.add(body);
      }
    });
  }

  ref.onDispose(() {
    ws.unsubscribe('/topic/order/$orderId/status');
    controller.close();
  });

  return controller.stream;
});

// ─── Quotation Notifier ──────────────────────────────────────────────────────

class QuotationNotifier extends AsyncNotifier<Order?> {
  @override
  Future<Order?> build() async => null;

  Future<bool> submit({
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
    state = const AsyncLoading();
    final result = await AsyncValue.guard(
      () => ref.read(orderRepositoryProvider).createQuotation(
            productId: productId,
            vehicleBrand: vehicleBrand,
            bodyType: bodyType,
            bodySize: bodySize,
            lengthCm: lengthCm,
            widthCm: widthCm,
            heightCm: heightCm,
            options: options,
            note: note,
          ),
    );
    state = result;
    return result.hasValue && result.value != null;
  }

  Future<bool> submitGuest({
    required String phone,
    String? fullName,
    String? productId,
    String? vehicleBrand,
    String? bodyType,
    String? bodySize,
    double? lengthCm,
    double? widthCm,
    double? heightCm,
    List<String>? options,
    String? note,
  }) async {
    state = const AsyncLoading();
    final api = ref.read(apiServiceProvider);
    final result = await AsyncValue.guard(() async {
      await api.post(
        ApiConstants.createGuestQuotation,
        data: {
          'phone': phone,
          if (fullName != null) 'fullName': fullName,
          if (productId != null) 'productId': int.tryParse(productId),
          if (vehicleBrand != null) 'vehicleBrand': vehicleBrand,
          if (bodyType != null) 'bodyType': bodyType,
          if (bodySize != null) 'bodySize': bodySize,
          if (lengthCm != null) 'lengthCm': lengthCm,
          if (widthCm != null) 'widthCm': widthCm,
          if (heightCm != null) 'heightCm': heightCm,
          if (options != null && options.isNotEmpty) 'options': options,
          if (note != null) 'note': note,
        },
      );
      return null as Order?;
    });
    state = result;
    return !result.hasError;
  }
}

final quotationProvider =
    AsyncNotifierProvider<QuotationNotifier, Order?>(QuotationNotifier.new);

// ─── Order Actions ────────────────────────────────────────────────────────────

class OrderActionsNotifier extends Notifier<void> {
  @override
  void build() {}

  /// Khach hang gui yeu cau huy don hang.
  Future<void> cancelOrder(String orderId) async {
    await ref.read(apiServiceProvider).patch<void>(
      ApiConstants.resolve(ApiConstants.cancelOrder, {'id': orderId}),
      data: {},
    );
    ref.invalidate(orderListProvider);
    ref.invalidate(orderDetailProvider(orderId));
  }

  /// Staff duyet yeu cau huy don hang => CANCELLED.
  Future<void> approveCancel(String orderId, {String? note}) async {
    final url = ApiConstants.resolve(ApiConstants.staffApproveCancel, {'id': orderId});
    await ref.read(apiServiceProvider).patch<void>(
      note != null ? '$url?note=${Uri.encodeComponent(note)}' : url,
      data: {},
    );
    ref.invalidate(orderListProvider);
    ref.invalidate(orderDetailProvider(orderId));
  }

  /// Staff tu choi yeu cau huy => tra ve PENDING.
  Future<void> rejectCancel(String orderId, {String? note}) async {
    final url = ApiConstants.resolve(ApiConstants.staffRejectCancel, {'id': orderId});
    await ref.read(apiServiceProvider).patch<void>(
      note != null ? '$url?note=${Uri.encodeComponent(note)}' : url,
      data: {},
    );
    ref.invalidate(orderListProvider);
    ref.invalidate(orderDetailProvider(orderId));
  }
}

final orderActionsProvider =
    NotifierProvider<OrderActionsNotifier, void>(OrderActionsNotifier.new);
