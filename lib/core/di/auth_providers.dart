import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import 'notification_providers.dart';
import 'service_providers.dart';

// ─── Auth State ──────────────────────────────────────────────────────────────

class AuthNotifier extends AsyncNotifier<User?> {
  AuthRepository get _repo => ref.read(authRepositoryProvider);

  @override
  Future<User?> build() async {
    final loggedIn = await ref.read(tokenServiceProvider).isLoggedIn();
    if (!loggedIn) return null;

    _connectWebSocket();
    _registerPushNotifications();

    try {
      return await _repo.getProfile();
    } catch (_) {
      return null;
    }
  }

  Future<void> _connectWebSocket() async {
    final token = await ref.read(tokenServiceProvider).getAccessToken();
    if (token != null) {
      try {
        await ref.read(webSocketServiceProvider).connect(token: token);
      } catch (_) {}
    }
  }

  Future<void> _registerPushNotifications() async {
    try {
      await ref.read(pushNotificationServiceProvider).init();
    } catch (_) {}
  }

  Future<void> login(
      {required String phone, required String password}) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
        () => _repo.login(phone: phone, password: password));
    if (state.hasValue && state.value != null) {
      _connectWebSocket();
      _registerPushNotifications();
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
      _registerPushNotifications();
    }
  }

  Future<void> loginWithZalo(String zaloCode) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _repo.loginWithZalo(zaloCode));
    if (state.hasValue && state.value != null) {
      _connectWebSocket();
      _registerPushNotifications();
    }
  }

  Future<void> logout() async {
    try {
      await ref.read(pushNotificationServiceProvider).removeToken();
    } catch (_) {}
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

// ─── Home Tab Index ──────────────────────────────────────────────────────────

final homeTabIndexProvider = StateProvider<int>((ref) => 0);
