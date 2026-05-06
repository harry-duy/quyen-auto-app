import '../services/api_service.dart';
import '../services/websocket_service.dart';

// TODO: Combine REST (history) + WebSocket (realtime) for chat

class ChatRepositoryImpl {
  // ignore: unused_field
  final ApiService _api;
  final WebSocketService _ws;

  ChatRepositoryImpl(this._api, this._ws);

  // ignore: unused_field — will be used when chat history API is implemented
  Future<List<Map<String, dynamic>>> getChatHistory() async {
    // TODO: call _api for chat history
    return [];
  }

  void sendMessage(String message) {
    _ws.send('/app/chat.send', message);
  }
}
