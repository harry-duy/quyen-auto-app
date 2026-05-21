import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../core/constants/api_constants.dart';
import '../../core/constants/app_colors.dart';
import '../../core/di/auth_providers.dart';
import '../../core/di/chat_providers.dart';
import '../../core/di/service_providers.dart';
import '../../data/models/response/chat_response.dart';
import '../../data/repositories/chat_repository_impl.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final String roomId;
  const ChatScreen({super.key, required this.roomId});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _textController = TextEditingController();
  final _scrollController = ScrollController();
  bool _uploading = false;
  Timer? _typingTimer;

  @override
  void initState() {
    super.initState();
    _textController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _typingTimer?.cancel();
    _textController.removeListener(_onTextChanged);
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final repo = ref.read(chatRepositoryProvider);
    repo.sendTyping(widget.roomId, true);
    _typingTimer?.cancel();
    _typingTimer = Timer(const Duration(seconds: 2), () {
      repo.sendTyping(widget.roomId, false);
    });
  }

  void _send() {
    final text = _textController.text.trim();
    if (text.isEmpty) return;
    _typingTimer?.cancel();
    ref.read(chatRepositoryProvider).sendTyping(widget.roomId, false);
    ref.read(activeChatProvider(widget.roomId).notifier).send(text);
    _textController.clear();
    _scrollToBottom();
  }

  Future<void> _sendImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
        source: ImageSource.gallery, imageQuality: 80);
    if (picked == null) return;
    setState(() => _uploading = true);
    try {
      final api = ref.read(apiServiceProvider);
      final form = FormData.fromMap({
        'file': await MultipartFile.fromFile(picked.path),
        'folder': 'chat',
      });
      final res = await api.postMultipart<String>(
        ApiConstants.upload,
        formData: form,
        fromData: (json) => json as String,
      );
      if (res.data != null) {
        ref
            .read(activeChatProvider(widget.roomId).notifier)
            .sendImage(res.data!);
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Không upload được ảnh: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 120), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(activeChatProvider(widget.roomId));
    final currentUser = ref.watch(authProvider).valueOrNull;
    final isTyping = ref.watch(typingProvider(widget.roomId));
    final rooms = ref.watch(chatRoomsProvider).valueOrNull;
    ChatRoomResponse? room;
    if (rooms != null && rooms.isNotEmpty) {
      try {
        room = rooms.firstWhere((r) => r.id.toString() == widget.roomId);
      } catch (_) {
        room = rooms.first;
      }
    }

    ref.listen(activeChatProvider(widget.roomId), (prev, next) {
      if ((prev == null || prev.isEmpty) && next.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients) {
            _scrollController.jumpTo(
                _scrollController.position.maxScrollExtent);
          }
        });
      }
    });

    final isCustomerView = currentUser?.id == room?.customerId.toString();
    final chatTitle = isCustomerView
        ? (room?.staffName ?? 'Đang chờ hỗ trợ')
        : (room?.customerName ?? 'Chat');
    final avatarName = chatTitle;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      appBar: AppBar(
        backgroundColor: AppColors.primaryNavy,
        foregroundColor: AppColors.textWhite,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Row(
          children: [
            _Avatar(name: avatarName, size: 36),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(chatTitle,
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w600)),
                if (isTyping)
                  const Text('Đang nhập...',
                      style: TextStyle(
                          fontSize: 11, color: Colors.white70,
                          fontStyle: FontStyle.italic))
                else if (room?.orderCode != null)
                  Text('Đơn: ${room!.orderCode}',
                      style: const TextStyle(
                          fontSize: 11, color: Colors.white70)),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all),
            tooltip: 'Đánh dấu đã đọc',
            onPressed: () => ref
                .read(chatActionsProvider.notifier)
                .markAsRead(widget.roomId),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: messages.isEmpty
                ? const Center(
                    child: Text('Chưa có tin nhắn',
                        style: TextStyle(color: AppColors.textGray)))
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
                    itemCount: messages.length,
                    itemBuilder: (_, i) {
                      final msg = messages[i];
                      final isMine =
                          msg.senderId.toString() == currentUser?.id;
                      final showDate = i == 0 ||
                          !_sameDay(
                              messages[i - 1].createdAt, msg.createdAt);
                      return Column(
                        children: [
                          if (showDate) _DateDivider(date: msg.createdAt),
                          _MessageBubble(message: msg, isMine: isMine),
                        ],
                      );
                    },
                  ),
          ),
          if (isTyping)
            const Padding(
              padding: EdgeInsets.only(left: 16, bottom: 4),
              child: Align(
                alignment: Alignment.centerLeft,
                child: _TypingBubble(),
              ),
            ),
          _InputBar(
            controller: _textController,
            onSend: _send,
            onPickImage: _sendImage,
            uploading: _uploading,
          ),
        ],
      ),
    );
  }

  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}

// ─── Message Bubble ───────────────────────────────────────────────────────────

class _MessageBubble extends StatelessWidget {
  final MessageResponse message;
  final bool isMine;

  const _MessageBubble({required this.message, required this.isMine});

  @override
  Widget build(BuildContext context) {
    final timeFmt = DateFormat('HH:mm');
    final isImage = message.type == 'IMAGE';

    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 3),
        constraints:
            BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.72),
        decoration: isImage
            ? null
            : BoxDecoration(
                color: isMine ? AppColors.primaryOrange : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isMine ? 16 : 4),
                  bottomRight: Radius.circular(isMine ? 4 : 16),
                ),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withAlpha(18),
                      blurRadius: 4,
                      offset: const Offset(0, 2)),
                ],
              ),
        padding: isImage
            ? EdgeInsets.zero
            : const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          crossAxisAlignment:
              isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            if (!isMine && !isImage)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  message.senderName,
                  style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryNavy),
                ),
              ),
            if (isImage)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CachedNetworkImage(
                  imageUrl: message.content,
                  width: 200,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => Container(
                    width: 200,
                    height: 150,
                    color: AppColors.borderLight,
                    child: const Center(child: CircularProgressIndicator()),
                  ),
                  errorWidget: (_, __, ___) => Container(
                    width: 200,
                    height: 150,
                    color: AppColors.borderLight,
                    child: const Icon(Icons.broken_image,
                        color: AppColors.textGray),
                  ),
                ),
              )
            else
              Text(
                message.content,
                style: TextStyle(
                    fontSize: 14,
                    color: isMine ? Colors.white : AppColors.textDark),
              ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  timeFmt.format(message.createdAt),
                  style: TextStyle(
                      fontSize: 10,
                      color: isMine
                          ? Colors.white.withAlpha(180)
                          : AppColors.textGray),
                ),
                if (isMine) ...[
                  const SizedBox(width: 4),
                  Icon(
                    message.isRead ? Icons.done_all : Icons.done,
                    size: 13,
                    color: message.isRead
                        ? const Color(0xFF4FC3F7)
                        : Colors.white.withAlpha(180),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Date Divider ─────────────────────────────────────────────────────────────

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
      padding: const EdgeInsets.symmetric(vertical: 8),
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

// ─── Typing Bubble ────────────────────────────────────────────────────────────

class _TypingBubble extends StatefulWidget {
  const _TypingBubble();

  @override
  State<_TypingBubble> createState() => _TypingBubbleState();
}

class _TypingBubbleState extends State<_TypingBubble>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800))
      ..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
          bottomRight: Radius.circular(16),
          bottomLeft: Radius.circular(4),
        ),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withAlpha(15),
              blurRadius: 4,
              offset: const Offset(0, 2))
        ],
      ),
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (_, __) => Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            final offset = (i * 0.3);
            final t = (_ctrl.value - offset).clamp(0.0, 1.0);
            final scale = 0.6 + 0.4 * (0.5 - (t - 0.5).abs()) * 2;
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 2),
              width: 7,
              height: 7,
              decoration: BoxDecoration(
                  color: AppColors.textGray.withAlpha(
                      (180 + 75 * scale).round().clamp(0, 255)),
                  shape: BoxShape.circle),
            );
          }),
        ),
      ),
    );
  }
}

// ─── Avatar ───────────────────────────────────────────────────────────────────

class _Avatar extends StatelessWidget {
  final String name;
  final double size;
  const _Avatar({required this.name, this.size = 32});

  @override
  Widget build(BuildContext context) {
    final initials = name.isNotEmpty
        ? name.trim().split(' ').map((w) => w[0]).take(2).join().toUpperCase()
        : '?';
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
          color: Colors.white24, shape: BoxShape.circle),
      child: Center(
        child: Text(initials,
            style: TextStyle(
                fontSize: size * 0.36,
                color: Colors.white,
                fontWeight: FontWeight.w700)),
      ),
    );
  }
}

// ─── Input Bar ────────────────────────────────────────────────────────────────

class _InputBar extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  final VoidCallback onPickImage;
  final bool uploading;

  const _InputBar({
    required this.controller,
    required this.onSend,
    required this.onPickImage,
    required this.uploading,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              color: Colors.black.withAlpha(15),
              blurRadius: 8,
              offset: const Offset(0, -2)),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // image pick button
            uploading
                ? const Padding(
                    padding: EdgeInsets.all(8),
                    child: SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.primaryOrange)),
                  )
                : IconButton(
                    icon: const Icon(Icons.image_outlined,
                        color: AppColors.textGray),
                    onPressed: onPickImage,
                    tooltip: 'Gửi ảnh',
                  ),
            Expanded(
              child: TextField(
                controller: controller,
                maxLines: null,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => onSend(),
                decoration: InputDecoration(
                  hintText: 'Nhập tin nhắn...',
                  hintStyle:
                      const TextStyle(color: AppColors.textGray, fontSize: 14),
                  filled: true,
                  fillColor: const Color(0xFFF5F5F5),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Material(
              color: AppColors.primaryOrange,
              borderRadius: BorderRadius.circular(24),
              child: InkWell(
                borderRadius: BorderRadius.circular(24),
                onTap: onSend,
                child: const Padding(
                  padding: EdgeInsets.all(10),
                  child: Icon(Icons.send_rounded,
                      color: Colors.white, size: 22),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
