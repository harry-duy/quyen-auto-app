import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/constants/app_colors.dart';
import '../../core/di/auth_providers.dart';
import '../../core/di/chat_providers.dart';
import '../../data/models/response/chat_response.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final String roomId;
  const ChatScreen({super.key, required this.roomId});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _textController = TextEditingController();
  final _scrollController = ScrollController();
  bool _historyLoaded = false;

  @override
  void initState() {
    super.initState();
    // Load history after first frame
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _loadHistory();
    });
  }

  Future<void> _loadHistory() async {
    final history =
        await ref.read(chatHistoryProvider(widget.roomId).future);
    if (mounted) {
      ref
          .read(chatRoomNotifierProvider(widget.roomId).notifier)
          .loadHistory(history);
      setState(() => _historyLoaded = true);
      // Mark as read
      ref
          .read(chatRoomNotifierProvider(widget.roomId).notifier)
          .markAsRead(int.parse(widget.roomId));
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendMessage() {
    final text = _textController.text.trim();
    if (text.isEmpty) return;
    _textController.clear();
    ref
        .read(chatRoomNotifierProvider(widget.roomId).notifier)
        .sendMessage(int.parse(widget.roomId), text);
    _scrollToBottom();
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(chatRoomNotifierProvider(widget.roomId));
    final currentUser = ref.watch(authProvider).valueOrNull;
    final myId = currentUser?.id;

    // Auto-scroll when new messages arrive
    ref.listen(chatRoomNotifierProvider(widget.roomId), (_, __) {
      _scrollToBottom();
    });

    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: AppBar(
        backgroundColor: AppColors.primaryNavy,
        foregroundColor: AppColors.textWhite,
        title: Row(children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.primaryOrange,
            child: const Icon(Icons.headset_mic,
                color: Colors.white, size: 18),
          ),
          const SizedBox(width: 10),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Hỗ trợ Quyen Auto',
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.white)),
              Text('Phòng hỗ trợ',
                  style: TextStyle(fontSize: 11, color: Colors.white70)),
            ],
          ),
        ]),
      ),
      body: Column(
        children: [
          // ── Message list ───────────────────────────────────────────────
          Expanded(
            child: !_historyLoaded
                ? const Center(child: CircularProgressIndicator())
                : messages.isEmpty
                    ? const Center(
                        child: Text(
                          'Hãy bắt đầu cuộc trò chuyện…',
                          style: TextStyle(
                              color: AppColors.textGray, fontSize: 13),
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                        itemCount: messages.length,
                        itemBuilder: (_, i) {
                          final msg = messages[i];
                          final isMe = myId != null &&
                              msg.senderId == int.tryParse(myId);
                          final showDate = i == 0 ||
                              !_sameDay(
                                  messages[i - 1].createdAt,
                                  msg.createdAt);
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              if (showDate)
                                _DateDivider(date: msg.createdAt),
                              _MessageBubble(
                                  message: msg, isMe: isMe),
                            ],
                          );
                        },
                      ),
          ),

          // ── Input bar ──────────────────────────────────────────────────
          Container(
            color: AppColors.surface,
            padding: EdgeInsets.only(
              left: 12,
              right: 8,
              top: 8,
              bottom: MediaQuery.of(context).viewInsets.bottom + 8,
            ),
            child: SafeArea(
              top: false,
              child: Row(children: [
                Expanded(
                  child: TextField(
                    controller: _textController,
                    maxLines: 4,
                    minLines: 1,
                    textCapitalization:
                        TextCapitalization.sentences,
                    decoration: InputDecoration(
                      hintText: 'Nhập tin nhắn…',
                      hintStyle: const TextStyle(
                          color: AppColors.textGray, fontSize: 14),
                      filled: true,
                      fillColor: const Color(0xFFF0F2F5),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(22),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 6),
                Material(
                  color: AppColors.primaryOrange,
                  shape: const CircleBorder(),
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: _sendMessage,
                    child: const Padding(
                      padding: EdgeInsets.all(10),
                      child: Icon(Icons.send,
                          color: Colors.white, size: 20),
                    ),
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}

// ─── Date divider ─────────────────────────────────────────────────────────────

class _DateDivider extends StatelessWidget {
  final DateTime date;
  const _DateDivider({required this.date});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    String label;
    if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day) {
      label = 'Hôm nay';
    } else if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day - 1) {
      label = 'Hôm qua';
    } else {
      label = DateFormat('dd/MM/yyyy').format(date);
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(children: [
        const Expanded(child: Divider()),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text(label,
              style: const TextStyle(
                  fontSize: 11, color: AppColors.textGray)),
        ),
        const Expanded(child: Divider()),
      ]),
    );
  }
}

// ─── Message bubble ───────────────────────────────────────────────────────────

class _MessageBubble extends StatelessWidget {
  final MessageResponse message;
  final bool isMe;
  const _MessageBubble({required this.message, required this.isMe});

  @override
  Widget build(BuildContext context) {
    final timeFmt = DateFormat('HH:mm');

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Avatar (other side only)
          if (!isMe) ...[
            CircleAvatar(
              radius: 15,
              backgroundColor: AppColors.primaryNavy.withValues(alpha: 0.2),
              backgroundImage: message.senderAvatar != null
                  ? NetworkImage(message.senderAvatar!)
                  : null,
              child: message.senderAvatar == null
                  ? Text(
                      message.senderName.isNotEmpty
                          ? message.senderName[0].toUpperCase()
                          : '?',
                      style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.primaryNavy,
                          fontWeight: FontWeight.w600),
                    )
                  : null,
            ),
            const SizedBox(width: 6),
          ],

          // Bubble
          ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.7,
            ),
            child: Column(
              crossAxisAlignment: isMe
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                // Sender name (other side only)
                if (!isMe)
                  Padding(
                    padding: const EdgeInsets.only(left: 4, bottom: 2),
                    child: Text(
                      message.senderName,
                      style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textGray),
                    ),
                  ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isMe
                        ? AppColors.primaryOrange
                        : AppColors.surface,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: Radius.circular(isMe ? 16 : 4),
                      bottomRight: Radius.circular(isMe ? 4 : 16),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.07),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Text(
                    message.content,
                    style: TextStyle(
                      fontSize: 14,
                      color: isMe ? Colors.white : AppColors.textDark,
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      timeFmt.format(message.createdAt),
                      style: const TextStyle(
                          fontSize: 10, color: AppColors.textGray),
                    ),
                    if (isMe) ...[
                      const SizedBox(width: 3),
                      Icon(
                        message.isRead
                            ? Icons.done_all
                            : Icons.done,
                        size: 12,
                        color: message.isRead
                            ? AppColors.infoBlue
                            : AppColors.textGray,
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),

          // Spacer for my messages
          if (isMe) const SizedBox(width: 4),
        ],
      ),
    );
  }
}
