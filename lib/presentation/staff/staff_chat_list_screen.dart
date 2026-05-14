import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/constants/api_constants.dart';
import '../../core/constants/app_colors.dart';
import '../../core/di/service_providers.dart';
import '../../core/router/staff_router.dart';
import '../../data/models/response/chat_response.dart';

final _staffChatRoomsProvider =
    FutureProvider.autoDispose<List<ChatRoomResponse>>((ref) async {
  final api = ref.watch(apiServiceProvider);
  final res = await api.get<List<ChatRoomResponse>>(
    ApiConstants.chatRooms,
    fromData: (json) => (json as List)
        .map((e) => ChatRoomResponse.fromJson(e as Map<String, dynamic>))
        .toList(),
  );
  return res.data ?? [];
});

class StaffChatListScreen extends ConsumerWidget {
  const StaffChatListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final roomsAsync = ref.watch(_staffChatRoomsProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(title: const Text('Tin nhắn')),
      body: roomsAsync.when(
        data: (rooms) {
          if (rooms.isEmpty) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.chat_bubble_outline,
                      color: AppColors.textGray, size: 48),
                  SizedBox(height: 8),
                  Text('Chưa có cuộc hội thoại',
                      style:
                          TextStyle(color: AppColors.textGray, fontSize: 14)),
                ],
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () async =>
                ref.invalidate(_staffChatRoomsProvider),
            child: ListView.separated(
              itemCount: rooms.length,
              separatorBuilder: (_, __) =>
                  const Divider(height: 1, indent: 72),
              itemBuilder: (_, i) => _ChatRoomTile(room: rooms[i]),
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
              Text(e.toString(),
                  style: const TextStyle(color: AppColors.errorRed)),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChatRoomTile extends StatelessWidget {
  final ChatRoomResponse room;
  const _ChatRoomTile({required this.room});

  @override
  Widget build(BuildContext context) {
    final timeFmt = DateFormat('HH:mm');

    // Customer name — show name if available, fall back to ID
    final customerLabel =
        room.customerName?.isNotEmpty == true
            ? room.customerName!
            : 'Khách hàng #${room.customerId}';

    return ListTile(
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      leading: CircleAvatar(
        radius: 24,
        backgroundColor: AppColors.primaryNavy,
        backgroundImage: room.customerAvatar != null
            ? NetworkImage(room.customerAvatar!)
            : null,
        child: room.customerAvatar == null
            ? Text(
                customerLabel.isNotEmpty
                    ? customerLabel[0].toUpperCase()
                    : 'C',
                style: const TextStyle(
                    color: AppColors.textWhite,
                    fontWeight: FontWeight.w700,
                    fontSize: 16))
            : null,
      ),
      title: Text(customerLabel,
          style: TextStyle(
              fontSize: 14,
              fontWeight:
                  room.unreadCount > 0 ? FontWeight.w700 : FontWeight.w500,
              color: AppColors.textDark)),
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
      onTap: () => context.push(StaffRoutes.chatOf(room.id.toString())),
    );
  }
}
