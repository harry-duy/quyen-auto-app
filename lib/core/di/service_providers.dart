import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/auth_repository_impl.dart';
import '../../data/repositories/chat_repository_impl.dart';
import '../../data/repositories/order_repository_impl.dart';
import '../../data/repositories/product_repository_impl.dart';
import '../../data/repositories/warranty_repository_impl.dart';
import '../../data/services/api_service.dart';
import '../../data/services/token_service.dart';
import '../../data/services/websocket_service.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/order_repository.dart';
import '../../domain/repositories/product_repository.dart';
import '../../domain/repositories/warranty_repository.dart';

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

final warrantyRepositoryProvider = Provider<WarrantyRepository>((ref) {
  return WarrantyRepositoryImpl(ref.watch(apiServiceProvider));
});

final chatRepositoryProvider = Provider<ChatRepositoryImpl>((ref) {
  return ChatRepositoryImpl(
      ref.watch(apiServiceProvider), ref.watch(webSocketServiceProvider));
});
