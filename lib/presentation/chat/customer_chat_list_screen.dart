import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/constants/app_colors.dart';
import '../../core/di/chat_providers.dart';
import '../../core/router/app_router.dart';
import '../../data/models/response/chat_response.dart';

class CustomerChatListScreen extends ConsumerWidget {
  const CustomerChatListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final roomsAsync = ref.watch(chatRoomsProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(title: const Text('Hỗ trợ khách hàng')),
      body: roomsAsync.when(
        data: (rooms) {
          if (rooms.isEmpty) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.support_agent_outlined,
                      color: AppColors.textGray, size: 52),
                  SizedBox(height: 12),
                  Text('Chưa có cuộc hội thoại nào',
                      style:
                          TextStyle(color: AppColors.textGray, fontSize: 14)),
                  SizedBox(height: 6),
                  Text(
                    'Liên hệ Quyen Auto qua hotline để bắt đầu',
                    style:
                        TextStyle(color: AppColors.textGray, fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }
          // If only one room, auto-navigate
          if (rooms.length == 1) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              context.replace(AppRoutes.chatOf(rooms.first.id.toString()));
            });
            return const Center(child: CircularProgressIndicator());
          }
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(chatRoomsProvider),
            child: ListView.separated(
              itemCount: rooms.length,
              separatorBuilder: (_, __) =>
                  const Divider(height: 1, indent: 72),
              itemBuilder: (_, i) =>
                  _CustomerChatRoomTile(room: rooms[i]),
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
                  style:
                      const TextStyle(color: AppColors.errorRed, fontSize: 13),
                  textAlign: TextAlign.center),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => ref.invalidate(chatRoomsProvider),
                child: const Text('Thử lại'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CustomerChatRoomTile extends StatelessWidget {
  final ChatRoomResponse room;
  const _CustomerChatRoomTile({required this.room});

  @override
  Widget build(BuildContext context) {
    final timeFmt = DateFormat('HH:mm');

    return ListTile(
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      leading: CircleAvatar(
        radius: 24,
        backgroundColor: AppColors.primaryOrange,
        backgroundImage: room.staffAvatar != null
            ? NetworkImage(room.staffAvatar!)
            : null,
        child: room.staffAvatar == null
            ? const Icon(Icons.support_agent,
                color: Colors.white, size: 22)
            : null,
      ),
      title: Text(
        room.staffName.isNotEmpty
            ? room.staffName
            : 'Nhân viên hỗ trợ',
        style: TextStyle(
            fontSize: 14,
            fontWeight:
                room.unreadCount > 0 ? FontWeight.w700 : FontWeight.w500,
            color: AppColors.textDark),
      ),
      subtitle: room.lastMessage != null
          ? Text(
              room.lastMessage!,
              style: TextStyle(
                  fontSize: 12,
                  color: room.unreadCount > 0
                      ? AppColors.textDark
                      : AppColors.textGray),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            )
          : const Text('Chưa có tin nhắn',
              style: TextStyle(fontSize: 12, color: AppColors.textGray)),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (room.lastMessageAt != null)
            Text(timeFmt.format(room.lastMessageAt!),
                style: const TextStyle(
                    fontSize: 10, color: AppColors.textGray)),
          if (room.unreadCount > 0) ...[
            const SizedBox(height: 4),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.primaryOrange,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text('${room.unreadCount}',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w600)),
            ),
          ],
        ],
      ),
      onTap: () => context.push(AppRoutes.chatOf(room.id.toString())),
    );
  }
}
