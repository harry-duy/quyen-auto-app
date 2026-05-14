import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/api_constants.dart';
import '../../data/models/response/chat_response.dart';
import 'service_providers.dart';

// ─── Customer / Staff: chat rooms ────────────────────────────────────────────

final chatRoomsProvider =
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

// ─── Chat message history (paginated REST) ───────────────────────────────────

final chatHistoryProvider = FutureProvider.autoDispose
    .family<List<MessageResponse>, String>((ref, roomId) async {
  final api = ref.watch(apiServiceProvider);
  final res = await api.get<List<MessageResponse>>(
    ApiConstants.resolve(ApiConstants.chatMessages, {'roomId': roomId}),
    queryParams: {'page': 0, 'size': 100, 'sort': 'createdAt,asc'},
    fromData: (json) {
      final list = json is Map<String, dynamic> && json['content'] is List
          ? json['content'] as List
          : json as List;
      return list
          .map((e) => MessageResponse.fromJson(e as Map<String, dynamic>))
          .toList();
    },
  );
  return res.data ?? [];
});

// ─── Real-time chat state (history + WebSocket) ───────────────────────────────

class ChatRoomNotifier
    extends AutoDisposeFamilyNotifier<List<MessageResponse>, String> {
  @override
  List<MessageResponse> build(String roomId) {
    final ws = ref.watch(webSocketServiceProvider);
    ws.subscribeChat(roomId, (body) {
      try {
        final json = jsonDecode(body) as Map<String, dynamic>;
        final msg = MessageResponse.fromJson(json);
        // Append only if not already in the list (dedup by id)
        if (!state.any((m) => m.id == msg.id)) {
          state = [...state, msg];
        }
      } catch (_) {}
    });

    ref.onDispose(() => ws.unsubscribe('/topic/chat.room.$roomId'));
    return [];
  }

  /// Called once history is loaded — prepends historic messages to state.
  void loadHistory(List<MessageResponse> history) {
    final ids = state.map((m) => m.id).toSet();
    final newOnes = history.where((m) => !ids.contains(m.id)).toList();
    state = [...newOnes, ...state];
  }

  /// Send a text message via WebSocket.
  void sendMessage(int roomId, String content) {
    final ws = ref.read(webSocketServiceProvider);
    final payload = jsonEncode({
      'roomId': roomId,
      'content': content,
      'type': 'TEXT',
    });
    ws.send('/app/chat.send', payload);
  }

  /// Mark room as read via REST.
  Future<void> markAsRead(int roomId) async {
    try {
      await ref.read(apiServiceProvider).post<void>(
        ApiConstants.resolve(
            ApiConstants.chatMarkRead, {'roomId': roomId.toString()}),
        data: {},
      );
    } catch (_) {}
  }
}

final chatRoomNotifierProvider = NotifierProvider.autoDispose
    .family<ChatRoomNotifier, List<MessageResponse>, String>(
        ChatRoomNotifier.new);
