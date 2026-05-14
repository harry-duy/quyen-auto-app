import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/constants/app_colors.dart';
import '../../core/di/notification_providers.dart';
import '../../core/router/app_router.dart';
import '../../data/models/response/notification_response.dart';

class NotificationScreen extends ConsumerWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifAsync = ref.watch(notificationListProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Thông báo'),
        actions: [
          notifAsync.valueOrNull?.any((n) => !n.isRead) == true
              ? TextButton(
                  onPressed: () async {
                    try {
                      await ref
                          .read(notificationActionsProvider.notifier)
                          .markAllRead();
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text('$e'),
                              backgroundColor: AppColors.errorRed),
                        );
                      }
                    }
                  },
                  child: const Text('Đọc tất cả',
                      style: TextStyle(
                          color: AppColors.primaryOrange, fontSize: 13)),
                )
              : const SizedBox.shrink(),
        ],
      ),
      body: notifAsync.when(
        data: (list) {
          if (list.isEmpty) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.notifications_off_outlined,
                      color: AppColors.textGray, size: 52),
                  SizedBox(height: 12),
                  Text('Chưa có thông báo nào',
                      style:
                          TextStyle(color: AppColors.textGray, fontSize: 14)),
                ],
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () async =>
                ref.invalidate(notificationListProvider),
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: list.length,
              separatorBuilder: (_, __) =>
                  const Divider(height: 1, indent: 70),
              itemBuilder: (_, i) => _NotificationTile(item: list[i]),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline,
                  color: AppColors.errorRed, size: 40),
              const SizedBox(height: 8),
              Text('$e',
                  style: const TextStyle(
                      color: AppColors.errorRed, fontSize: 13),
                  textAlign: TextAlign.center),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () =>
                    ref.invalidate(notificationListProvider),
                child: const Text('Thử lại'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NotificationTile extends ConsumerWidget {
  final NotificationResponse item;
  const _NotificationTile({required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timeFmt = DateFormat('dd/MM HH:mm');

    final (icon, color) = switch (item.type.toUpperCase()) {
      'ORDER'     => (Icons.receipt_long_outlined, AppColors.infoBlue),
      'WARRANTY'  => (Icons.build_circle_outlined, AppColors.successGreen),
      'QUOTATION' => (Icons.request_quote_outlined, AppColors.primaryOrange),
      'SYSTEM'    => (Icons.info_outline, AppColors.textGray),
      _           => (Icons.notifications_outlined, AppColors.primaryNavy),
    };

    return InkWell(
      onTap: () {
        // Navigate to relevant screen
        _navigate(context, item);
        // Mark as read if not yet
        if (!item.isRead) {
          ref
              .read(notificationActionsProvider.notifier)
              .markOneRead(item.id)
              .ignore();
        }
      },
      child: Container(
        color: item.isRead
            ? Colors.transparent
            : AppColors.infoBlue.withValues(alpha: 0.05),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Expanded(
                      child: Text(
                        item.title,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: item.isRead
                              ? FontWeight.w500
                              : FontWeight.w700,
                          color: AppColors.textDark,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      timeFmt.format(item.createdAt),
                      style: const TextStyle(
                          fontSize: 10, color: AppColors.textGray),
                    ),
                    if (!item.isRead) ...[
                      const SizedBox(width: 6),
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppColors.primaryOrange,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ]),
                  const SizedBox(height: 3),
                  Text(
                    item.body,
                    style: TextStyle(
                        fontSize: 12,
                        color: item.isRead
                            ? AppColors.textGray
                            : AppColors.textDark),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigate(BuildContext context, NotificationResponse item) {
    if (item.refId == null) return;
    switch (item.type.toUpperCase()) {
      case 'ORDER':
        context.push(AppRoutes.orderOf(item.refId.toString()));
      case 'WARRANTY':
        // No separate customer warranty detail — go to warranty tab
        break;
      default:
        break;
    }
  }
}
