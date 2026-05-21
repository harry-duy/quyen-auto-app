import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/response/chat_response.dart';
import '../../data/repositories/chat_repository_impl.dart';
import 'auth_providers.dart';
import 'service_providers.dart';

// ─── Chat Rooms List ─────────────────────────────────────────────────────────

final chatRoomsProvider =
    FutureProvider.autoDispose<List<ChatRoomResponse>>((ref) async {
  final repo = ref.watch(chatRepositoryProvider);
  return repo.getChatRooms();
});

// ─── Chat Messages for a Room ─────────────────────────────────────────────────

final chatMessagesProvider = FutureProvider.autoDispose
    .family<List<MessageResponse>, String>((ref, roomId) async {
  final repo = ref.watch(chatRepositoryProvider);
  return repo.getChatMessages(roomId);
});

// ─── Active Room Notifier (real-time messages) ────────────────────────────────

class ActiveChatNotifier
    extends AutoDisposeFamilyNotifier<List<MessageResponse>, String> {
  @override
  List<MessageResponse> build(String roomId) {
    final ws = ref.read(webSocketServiceProvider);
    void onReconnect() => _load(roomId);
    ws.addReconnectListener(onReconnect);
    ref.onDispose(() {
      _repo.unsubscribeRoom(roomId);
      ws.removeReconnectListener(onReconnect);
    });
    _load(roomId);
    return [];
  }

  ChatRepositoryImpl get _repo => ref.read(chatRepositoryProvider);

  Future<void> _load(String roomId) async {
    final history = await _repo.getChatMessages(roomId);
    state = history.reversed.toList();
    _repo.subscribeRoom(roomId, (msg) {
      if (!state.any((m) => m.id == msg.id)) {
        state = [...state, msg];
      }
    });
  }

  void send(String content) {
    _repo.sendMessageViaWs(arg, content);
  }

  void sendImage(String imageUrl) {
    _repo.sendImageViaWs(arg, imageUrl);
  }
}

final activeChatProvider = NotifierProvider.autoDispose
    .family<ActiveChatNotifier, List<MessageResponse>, String>(
  ActiveChatNotifier.new,
);

// ─── Typing Indicator ─────────────────────────────────────────────────────────

class TypingNotifier
    extends AutoDisposeFamilyNotifier<bool, String> {
  Timer? _clearTimer;

  @override
  bool build(String roomId) {
    final currentUserId = ref.read(authProvider).valueOrNull?.id;
    final ws = ref.read(webSocketServiceProvider);
    ws.subscribeTyping(roomId, (body) {
      try {
        final map = jsonDecode(body) as Map<String, dynamic>;
        if (map['userId']?.toString() == currentUserId) return;
        final isTyping = map['typing'] == true;
        state = isTyping;
        _clearTimer?.cancel();
        if (isTyping) {
          _clearTimer = Timer(const Duration(seconds: 3), () {
            try { state = false; } catch (_) {}
          });
        }
      } catch (_) {}
    });
    ref.onDispose(() {
      _clearTimer?.cancel();
      ws.unsubscribeTyping(roomId);
    });
    return false;
  }
}

final typingProvider = NotifierProvider.autoDispose
    .family<TypingNotifier, bool, String>(TypingNotifier.new);

// ─── Staff Chat Actions ────────────────────────────────────────────────────────

class ChatActionsNotifier extends Notifier<void> {
  @override
  void build() {}

  ChatRepositoryImpl get _repo => ref.read(chatRepositoryProvider);

  Future<ChatRoomResponse> startChat(
      {String? orderCode, String? firstMessage}) async {
    final room = await _repo.startChat(
        orderCode: orderCode, firstMessage: firstMessage);
    ref.invalidate(chatRoomsProvider);
    return room;
  }

  Future<ChatRoomResponse> claimRoom(String roomId) async {
    final room = await _repo.claimRoom(roomId);
    ref.invalidate(chatRoomsProvider);
    return room;
  }

  Future<void> markAsRead(String roomId) async {
    await _repo.markAsRead(roomId);
    ref.invalidate(chatRoomsProvider);
  }
}

final chatActionsProvider =
    NotifierProvider<ChatActionsNotifier, void>(ChatActionsNotifier.new);
