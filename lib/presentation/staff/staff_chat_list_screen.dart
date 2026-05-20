import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/constants/app_colors.dart';
import '../../core/di/chat_providers.dart';
import '../../core/router/staff_router.dart';
import '../../data/models/response/chat_response.dart';

class StaffChatListScreen extends ConsumerWidget {
  const StaffChatListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final roomsAsync = ref.watch(chatRoomsProvider);

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
            onRefresh: () async => ref.invalidate(chatRoomsProvider),
            child: ListView.separated(
              itemCount: rooms.length,
              separatorBuilder: (_, _) =>
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

class _ChatRoomTile extends ConsumerWidget {
  final ChatRoomResponse room;
  const _ChatRoomTile({required this.room});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timeFmt = DateFormat('HH:mm');
    final initials = room.customerName.isNotEmpty
        ? room.customerName[0].toUpperCase()
        : 'K';

    return ListTile(
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      leading: Stack(
        clipBehavior: Clip.none,
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: room.isWaiting
                ? AppColors.primaryOrange
                : AppColors.primaryNavy,
            backgroundImage: room.customerAvatar != null
                ? NetworkImage(room.customerAvatar!)
                : null,
            child: room.customerAvatar == null
                ? Text(initials,
                    style: const TextStyle(
                        color: AppColors.textWhite,
                        fontWeight: FontWeight.w700,
                        fontSize: 16))
                : null,
          ),
          if (room.isWaiting)
            const Positioned(
              bottom: -2,
              right: -2,
              child: CircleAvatar(
                radius: 8,
                backgroundColor: Colors.white,
                child: CircleAvatar(
                  radius: 6,
                  backgroundColor: AppColors.primaryOrange,
                  child: Icon(Icons.hourglass_top,
                      size: 8, color: Colors.white),
                ),
              ),
            ),
        ],
      ),
      title: Row(
        children: [
          Expanded(
            child: Text(
              room.customerName,
              style: TextStyle(
                  fontSize: 14,
                  fontWeight:
                      room.unreadCount > 0 ? FontWeight.w700 : FontWeight.w500,
                  color: AppColors.textDark),
            ),
          ),
          if (room.orderCode != null)
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.primaryNavy.withAlpha(20),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                room.orderCode!,
                style: const TextStyle(
                    fontSize: 10, color: AppColors.primaryNavy),
              ),
            ),
        ],
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
                style:
                    const TextStyle(fontSize: 10, color: AppColors.textGray)),
          const SizedBox(height: 4),
          if (room.isWaiting)
            _ClaimButton(room: room)
          else if (room.unreadCount > 0)
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
      ),
      onTap: room.isWaiting
          ? null
          : () => context.push(StaffRoutes.chatOf(room.id.toString())),
    );
  }
}

class _ClaimButton extends ConsumerWidget {
  final ChatRoomResponse room;
  const _ClaimButton({required this.room});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ElevatedButton(
      onPressed: () async {
        try {
          await ref
              .read(chatActionsProvider.notifier)
              .claimRoom(room.id.toString());
          if (context.mounted) {
            context.push(StaffRoutes.chatOf(room.id.toString()));
          }
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text('Lỗi: $e'),
                  backgroundColor: AppColors.errorRed),
            );
          }
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryOrange,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        textStyle:
            const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
      ),
      child: const Text('Tiếp nhận'),
    );
  }
}
