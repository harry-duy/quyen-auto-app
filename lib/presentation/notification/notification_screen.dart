import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_colors.dart';
import '../../core/di/notification_providers.dart';
import '../../data/models/response/notification_response.dart';

class NotificationScreen extends ConsumerWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(notificationListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Thông báo'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(notificationListProvider),
          ),
        ],
      ),
      body: notificationsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: AppColors.textGray),
              const SizedBox(height: 12),
              Text('Không thể tải thông báo', style: TextStyle(color: AppColors.textGray)),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => ref.invalidate(notificationListProvider),
                child: const Text('Thử lại'),
              ),
            ],
          ),
        ),
        data: (notifications) {
          if (notifications.isEmpty) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.notifications_none, size: 64, color: AppColors.textGray),
                  SizedBox(height: 12),
                  Text('Chưa có thông báo', style: TextStyle(color: AppColors.textGray, fontSize: 16)),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(notificationListProvider),
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: notifications.length,
              separatorBuilder: (_, __) => const Divider(height: 1, indent: 72),
              itemBuilder: (context, index) => _NotificationTile(
                notification: notifications[index],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final NotificationResponse notification;
  const _NotificationTile({required this.notification});

  @override
  Widget build(BuildContext context) {
    final (icon, color) = _iconForType(notification.type);
    final timeAgo = _formatTimeAgo(notification.createdAt);

    return Container(
      color: notification.isRead ? null : AppColors.primaryOrange.withAlpha(15),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withAlpha(30),
          child: Icon(icon, color: color, size: 22),
        ),
        title: Text(
          notification.title,
          style: TextStyle(
            fontWeight: notification.isRead ? FontWeight.normal : FontWeight.w600,
            fontSize: 14,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 2),
            Text(notification.body, maxLines: 2, overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 13)),
            const SizedBox(height: 4),
            Text(timeAgo, style: const TextStyle(fontSize: 11, color: AppColors.textGray)),
          ],
        ),
        isThreeLine: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),
    );
  }

  (IconData, Color) _iconForType(String type) => switch (type) {
    'QUOTATION_NEW' => (Icons.request_quote, AppColors.primaryOrange),
    'ORDER_STATUS'  => (Icons.local_shipping, AppColors.infoBlue),
    'WARRANTY'      => (Icons.build_circle, AppColors.warningAmber),
    'CHAT'          => (Icons.chat_bubble, AppColors.successGreen),
    _               => (Icons.notifications, AppColors.textGray),
  };

  String _formatTimeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'Vừa xong';
    if (diff.inMinutes < 60) return '${diff.inMinutes} phút trước';
    if (diff.inHours < 24) return '${diff.inHours} giờ trước';
    if (diff.inDays < 7) return '${diff.inDays} ngày trước';
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}
