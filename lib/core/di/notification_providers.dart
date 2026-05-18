import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

import '../../data/models/response/notification_response.dart';
import '../../data/services/push_notification_service.dart';
import 'service_providers.dart';
import '../../core/constants/api_constants.dart';

// ─── Push Notification Service ──────────────────────────────────────────────

final pushNotificationServiceProvider = Provider<PushNotificationService>((ref) {
  return PushNotificationService(
    ref.watch(apiServiceProvider),
    ref.watch(tokenServiceProvider),
  );
});

// ─── Notification List (auto-refresh every 30s + WebSocket real-time) ────────

final notificationListProvider =
    AutoDisposeAsyncNotifierProvider<NotificationListNotifier, List<NotificationResponse>>(
  NotificationListNotifier.new,
);

class NotificationListNotifier extends AutoDisposeAsyncNotifier<List<NotificationResponse>> {
  final _log = Logger();
  Timer? _pollingTimer;

  @override
  Future<List<NotificationResponse>> build() async {
    ref.onDispose(() {
      _pollingTimer?.cancel();
    });

    _startPolling();
    _listenWebSocket();
    _listenFcm();

    return _fetchNotifications();
  }

  Future<List<NotificationResponse>> _fetchNotifications() async {
    final api = ref.read(apiServiceProvider);
    final res = await api.get<List<NotificationResponse>>(
      ApiConstants.notificationList,
      queryParams: {'page': 0, 'size': 50},
      fromData: (json) => (json as List)
          .map((e) => NotificationResponse.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
    return res.data ?? [];
  }

  void _startPolling() {
    _pollingTimer = Timer.periodic(const Duration(seconds: 30), (_) async {
      try {
        final fresh = await _fetchNotifications();
        state = AsyncData(fresh);
      } catch (e) {
        _log.w('Notification poll failed: $e');
      }
    });
  }

  void _listenWebSocket() {
    try {
      final ws = ref.read(webSocketServiceProvider);
      final tokenService = ref.read(tokenServiceProvider);

      tokenService.getAccessToken().then((token) {
        if (token == null || !ws.isConnected) return;

        // The userId is encoded in the JWT — we use a wildcard-style subscription
        // Backend sends to /user/{userId}/queue/notifications
        // STOMP user destination resolves automatically when authenticated
        ws.subscribeNotifications('', (body) {
          _log.i('WS notification received');
          _onNewNotification();
        });
      });
    } catch (e) {
      _log.w('WS notification subscription skipped: $e');
    }
  }

  void _listenFcm() {
    try {
      final push = ref.read(pushNotificationServiceProvider);
      push.onMessageReceived = (message) {
        _log.i('FCM notification received: ${message.notification?.title}');
        _onNewNotification();
      };
    } catch (e) {
      _log.w('FCM listener skipped: $e');
    }
  }

  void _onNewNotification() async {
    try {
      final fresh = await _fetchNotifications();
      state = AsyncData(fresh);
    } catch (e) {
      _log.w('Refresh after notification failed: $e');
    }
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = AsyncData(await _fetchNotifications());
  }
}

final unreadNotificationCountProvider = Provider<int>((ref) {
  final notifications = ref.watch(notificationListProvider).valueOrNull ?? [];
  return notifications.where((n) => !n.isRead).length;
});
