import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

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
    required String truckType,
    required double truckLength,
    required String requirements,
    String? note,
  }) async {
    state = const AsyncLoading();
    final result = await AsyncValue.guard(
      () => ref.read(orderRepositoryProvider).createQuotation(
            productId: productId,
            truckType: truckType,
            truckLength: truckLength,
            requirements: requirements,
            note: note,
          ),
    );
    state = result;
    return result.hasValue && result.value != null;
  }
}

final quotationProvider =
    AsyncNotifierProvider<QuotationNotifier, Order?>(QuotationNotifier.new);
