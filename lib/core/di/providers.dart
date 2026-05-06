import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/auth_repository_impl.dart';
import '../../data/repositories/order_repository_impl.dart';
import '../../data/repositories/product_repository_impl.dart';
import '../../data/services/api_service.dart';
import '../../data/services/token_service.dart';
import '../../data/services/websocket_service.dart';
import '../../domain/entities/order.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/order_repository.dart';
import '../../domain/repositories/product_repository.dart';

// ─── Services ────────────────────────────────────────────────────────────────

final tokenServiceProvider = Provider<TokenService>((_) => TokenService());

final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService(tokenService: ref.watch(tokenServiceProvider));
});

final webSocketServiceProvider = Provider<WebSocketService>((ref) {
  final ws = WebSocketService();
  ref.onDispose(() => ws.disconnect());
  return ws;
});

// ─── Repositories ────────────────────────────────────────────────────────────

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
      ref.watch(apiServiceProvider), ref.watch(tokenServiceProvider));
});

final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return ProductRepositoryImpl(ref.watch(apiServiceProvider));
});

final orderRepositoryProvider = Provider<OrderRepository>((ref) {
  return OrderRepositoryImpl(ref.watch(apiServiceProvider));
});

// ─── Auth State ──────────────────────────────────────────────────────────────

class AuthNotifier extends AsyncNotifier<User?> {
  AuthRepository get _repo => ref.read(authRepositoryProvider);

  @override
  Future<User?> build() async {
    final loggedIn = await ref.read(tokenServiceProvider).isLoggedIn();
    if (loggedIn) {
      _connectWebSocket();
      return const User(id: '', fullName: '', phone: '', role: '');
    }
    return null;
  }

  Future<void> _connectWebSocket() async {
    final token = await ref.read(tokenServiceProvider).getAccessToken();
    if (token != null) {
      try {
        await ref.read(webSocketServiceProvider).connect(token: token);
      } catch (_) {}
    }
  }

  Future<void> login(
      {required String phone, required String password}) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
        () => _repo.login(phone: phone, password: password));
    if (state.hasValue && state.value != null) {
      _connectWebSocket();
    }
  }

  Future<void> register({
    required String phone,
    required String fullName,
    String? email,
    String? companyName,
    required String password,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => _repo.register(
          phone: phone, fullName: fullName, email: email, password: password),
    );
    if (state.hasValue && state.value != null) {
      _connectWebSocket();
    }
  }

  Future<void> loginWithZalo(String zaloCode) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _repo.loginWithZalo(zaloCode));
    if (state.hasValue && state.value != null) {
      _connectWebSocket();
    }
  }

  Future<void> logout() async {
    ref.read(webSocketServiceProvider).disconnect();
    await _repo.logout();
    state = const AsyncData(null);
  }
}

final authProvider =
    AsyncNotifierProvider<AuthNotifier, User?>(AuthNotifier.new);

final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).valueOrNull != null;
});

// ─── RouterNotifier ──────────────────────────────────────────────────────────

class RouterNotifier extends ChangeNotifier {
  RouterNotifier(this._ref) {
    _ref.listen<AsyncValue<User?>>(authProvider, (_, __) => notifyListeners());
  }
  final Ref _ref;
}

final routerNotifierProvider =
    Provider<RouterNotifier>((ref) => RouterNotifier(ref));

// ─── Product Providers ───────────────────────────────────────────────────────

final productCategoryProvider = StateProvider<String?>((ref) => null);

final productListProvider =
    FutureProvider.autoDispose<List<Product>>((ref) async {
  final repo = ref.watch(productRepositoryProvider);
  final category = ref.watch(productCategoryProvider);
  return repo.getProducts(page: 0, size: 20, category: category);
});

final productDetailProvider =
    FutureProvider.autoDispose.family<Product, String>((ref, id) async {
  return ref.watch(productRepositoryProvider).getProductById(id);
});

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

// ─── Home Tab Index ──────────────────────────────────────────────────────────

final homeTabIndexProvider = StateProvider<int>((ref) => 0);
