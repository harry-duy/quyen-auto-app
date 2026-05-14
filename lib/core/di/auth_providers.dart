import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import 'service_providers.dart';

// ─── Auth State ──────────────────────────────────────────────────────────────

class AuthNotifier extends AsyncNotifier<User?> {
  AuthRepository get _repo => ref.read(authRepositoryProvider);

  @override
  Future<User?> build() async {
    final loggedIn = await ref.read(tokenServiceProvider).isLoggedIn();
    if (!loggedIn) return null;

    _connectWebSocket();
    _registerFcmToken();

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

  /// Lay FCM token va dang ky voi server (bo qua neu Firebase chua cau hinh)
  Future<void> _registerFcmToken() async {
    try {
      final messaging = FirebaseMessaging.instance;

      // Xin quyen thong bao (iOS / Android 13+)
      await messaging.requestPermission(alert: true, badge: true, sound: true);

      final fcmToken = await messaging.getToken();
      if (fcmToken == null) return;

      final api = ref.read(apiServiceProvider);
      await api.post<void>(
        'notifications/fcm-token',
        data: {'token': fcmToken, 'deviceType': 'MOBILE'},
      );
    } catch (_) {
      // Firebase chua cau hinh hoac thiet bi khong ho tro — bo qua
    }
  }

  Future<void> login(
      {required String phone, required String password}) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
        () => _repo.login(phone: phone, password: password));
    if (state.hasValue && state.value != null) {
      _connectWebSocket();
      _registerFcmToken();
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
      _registerFcmToken();
    }
  }

  Future<void> loginWithZalo(String zaloCode) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _repo.loginWithZalo(zaloCode));
    if (state.hasValue && state.value != null) {
      _connectWebSocket();
      _registerFcmToken();
    }
  }

  Future<void> logout() async {
    ref.read(webSocketServiceProvider).disconnect();
    await _repo.logout();
    state = const AsyncData(null);
  }

  Future<void> updateProfile({
    String? fullName,
    String? email,
    String? avatarUrl,
  }) async {
    final api = ref.read(apiServiceProvider);
    final result = await api.put<Map<String, dynamic>>(
      'auth/me',
      data: {
        if (fullName != null) 'fullName': fullName,
        if (email != null) 'email': email,
        if (avatarUrl != null) 'avatarUrl': avatarUrl,
      },
      fromData: (json) => json as Map<String, dynamic>,
    );
    // Re-fetch profile to keep state in sync
    if (result.data != null) {
      try {
        final updated = await _repo.getProfile();
        state = AsyncData(updated);
      } catch (_) {}
    }
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final api = ref.read(apiServiceProvider);
    await api.post<void>(
      'auth/change-password',
      data: {
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      },
    );
  }

  /// Gui lai OTP xac minh email
  Future<void> resendOtp() async {
    final api = ref.read(apiServiceProvider);
    await api.post<void>('auth/otp/send');
  }

  /// Xac minh OTP — cap nhat state khi thanh cong
  Future<void> verifyOtp(String code) async {
    final api = ref.read(apiServiceProvider);
    final result = await api.post<Map<String, dynamic>>(
      'auth/otp/verify',
      data: {'code': code},
      fromData: (json) => json as Map<String, dynamic>,
    );
    if (result.data != null) {
      // Re-fetch profile de cap nhat emailVerified = true trong state
      try {
        final updated = await _repo.getProfile();
        state = AsyncData(updated);
      } catch (_) {}
    }
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
