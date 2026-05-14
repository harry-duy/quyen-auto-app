import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/response/notification_response.dart';
import 'service_providers.dart';
import '../../core/constants/api_constants.dart';

// ─── Notification Providers ──────────────────────────────────────────────────

final notificationListProvider =
    FutureProvider.autoDispose<List<NotificationResponse>>((ref) async {
  final api = ref.watch(apiServiceProvider);
  final res = await api.get<List<NotificationResponse>>(
    ApiConstants.notificationList,
    queryParams: {'page': 0, 'size': 50},
    fromData: (json) => _items(json)
        .map((e) => NotificationResponse.fromJson(e as Map<String, dynamic>))
        .toList(),
  );
  return res.data ?? [];
});

final unreadNotificationCountProvider = Provider<int>((ref) {
  final notifications = ref.watch(notificationListProvider).valueOrNull ?? [];
  return notifications.where((n) => !n.isRead).length;
});

// ─── Notification Actions ────────────────────────────────────────────────────

class NotificationActionsNotifier extends Notifier<void> {
  @override
  void build() {}

  Future<void> markAllRead() async {
    await ref
        .read(apiServiceProvider)
        .post<void>(ApiConstants.notificationMarkRead, data: {});
    ref.invalidate(notificationListProvider);
  }

  Future<void> markOneRead(int id) async {
    await ref
        .read(apiServiceProvider)
        .post<void>('${ApiConstants.notificationList}/$id/read', data: {});
    ref.invalidate(notificationListProvider);
  }
}

final notificationActionsProvider =
    NotifierProvider<NotificationActionsNotifier, void>(
        NotificationActionsNotifier.new);

// ─── Helper ───────────────────────────────────────────────────────────────────

List<dynamic> _items(dynamic json) {
  if (json is Map<String, dynamic> && json['content'] is List) {
    return json['content'] as List;
  }
  return json as List;
}
