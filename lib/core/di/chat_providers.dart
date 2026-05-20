import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/response/chat_response.dart';
import '../../data/repositories/chat_repository_impl.dart';
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
    ref.onDispose(() => _repo.unsubscribeRoom(roomId));
    _load(roomId);
    return [];
  }

  ChatRepositoryImpl get _repo => ref.read(chatRepositoryProvider);

  Future<void> _load(String roomId) async {
    final history = await _repo.getChatMessages(roomId);
    state = history.reversed.toList();
    _repo.subscribeRoom(roomId, (msg) {
      state = [...state, msg];
    });
  }

  void send(String content) {
    _repo.sendMessageViaWs(arg, content);
  }
}

final activeChatProvider = NotifierProvider.autoDispose
    .family<ActiveChatNotifier, List<MessageResponse>, String>(
  ActiveChatNotifier.new,
);

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
