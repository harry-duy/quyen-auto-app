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
    fromData: (json) => (json as List)
        .map((e) => NotificationResponse.fromJson(e as Map<String, dynamic>))
        .toList(),
  );
  return res.data ?? [];
});

final unreadNotificationCountProvider = Provider<int>((ref) {
  final notifications = ref.watch(notificationListProvider).valueOrNull ?? [];
  return notifications.where((n) => !n.isRead).length;
});
