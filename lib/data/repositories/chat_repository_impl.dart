import 'dart:async';
import 'dart:convert';

import '../../core/constants/api_constants.dart';
import '../../data/models/response/chat_response.dart';
import '../services/api_service.dart';
import '../services/websocket_service.dart';

class ChatRepositoryImpl {
  final ApiService _api;
  final WebSocketService _ws;

  ChatRepositoryImpl(this._api, this._ws);

  Future<List<ChatRoomResponse>> getRooms() async {
    final res = await _api.get<List<ChatRoomResponse>>(
      ApiConstants.chatRooms,
      fromData: (json) => (json as List)
          .map((e) => ChatRoomResponse.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
    return res.data ?? [];
  }

  Future<List<MessageResponse>> getMessages(String roomId, {int page = 0}) async {
    final res = await _api.get<List<MessageResponse>>(
      ApiConstants.resolve(ApiConstants.chatMessages, {'roomId': roomId}),
      queryParams: {'page': page, 'size': 50},
      fromData: (json) {
        final content = json is Map ? (json['content'] as List?) ?? [] : json as List;
        return content
            .map((e) => MessageResponse.fromJson(e as Map<String, dynamic>))
            .toList();
      },
    );
    return res.data ?? [];
  }

  Future<void> markAsRead(String roomId) async {
    await _api.post<void>('chat/rooms/$roomId/read');
  }

  void sendMessage(String roomId, String content, {String type = 'TEXT'}) {
    final payload = jsonEncode({
      'roomId': int.parse(roomId),
      'content': content,
      'type': type,
    });
    _ws.send('/app/chat.send', payload);
  }

  StreamController<MessageResponse>? _messageController;

  Stream<MessageResponse> subscribeToRoom(String roomId) {
    _messageController?.close();
    _messageController = StreamController<MessageResponse>.broadcast();

    _ws.subscribeChat(roomId, (body) {
      try {
        final json = jsonDecode(body) as Map<String, dynamic>;
        _messageController?.add(MessageResponse.fromJson(json));
      } catch (_) {}
    });

    return _messageController!.stream;
  }

  void unsubscribeFromRoom(String roomId) {
    _ws.unsubscribe('/topic/room/$roomId');
    _messageController?.close();
    _messageController = null;
  }
}
