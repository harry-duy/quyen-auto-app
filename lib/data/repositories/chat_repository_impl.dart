import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../../core/constants/api_constants.dart';
import '../models/response/chat_response.dart';
import '../services/api_service.dart';
import '../services/websocket_service.dart';

class ChatRepositoryImpl {
  final ApiService _api;
  final WebSocketService _ws;

  ChatRepositoryImpl(this._api, this._ws);

  Future<List<ChatRoomResponse>> getChatRooms() async {
    final res = await _api.get<List<ChatRoomResponse>>(
      ApiConstants.chatRooms,
      fromData: (json) {
        final list = json == null
            ? <dynamic>[]
            : json is List
                ? json
                : (json as Map<String, dynamic>)['data'] as List? ?? [];
        return list
            .map((e) => ChatRoomResponse.fromJson(e as Map<String, dynamic>))
            .toList();
      },
    );
    return res.data ?? [];
  }

  Future<List<MessageResponse>> getChatMessages(String roomId,
      {int page = 0, int size = 50}) async {
    final res = await _api.get<List<MessageResponse>>(
      ApiConstants.resolve(ApiConstants.chatMessages, {'roomId': roomId}),
      queryParams: {'page': page, 'size': size},
      fromData: (json) {
        final List<dynamic> list;
        if (json is List) {
          // direct array response
          list = json;
        } else if (json is Map<String, dynamic>) {
          // ApiService already unwraps the top-level 'data' field,
          // so json is the paginated object: {"content":[...],...}
          list = json['content'] as List? ?? [];
        } else {
          list = [];
        }
        return list
            .map((e) => MessageResponse.fromJson(e as Map<String, dynamic>))
            .toList();
      },
    );
    return res.data ?? [];
  }

  Future<ChatRoomResponse> startChat({String? orderCode, String? firstMessage}) async {
    final res = await _api.post<ChatRoomResponse>(
      ApiConstants.chatStart,
      data: {
        'orderCode': ?orderCode,
        'firstMessage': ?firstMessage,
      },
      fromData: (json) => ChatRoomResponse.fromJson(
        _unwrap(json),
      ),
    );
    return res.data!;
  }

  Future<ChatRoomResponse> claimRoom(String roomId) async {
    final res = await _api.patch<ChatRoomResponse>(
      ApiConstants.resolve(ApiConstants.chatClaim, {'roomId': roomId}),
      fromData: (json) => ChatRoomResponse.fromJson(_unwrap(json)),
    );
    return res.data!;
  }

  Future<void> markAsRead(String roomId) async {
    await _api.post<void>(
      ApiConstants.resolve(ApiConstants.chatMarkRead, {'roomId': roomId}),
    );
  }

  void sendMessageViaWs(String roomId, String content) {
    _ws.send(
      '/app/chat.send',
      jsonEncode({'roomId': int.parse(roomId), 'content': content, 'type': 'TEXT'}),
    );
  }

  void sendImageViaWs(String roomId, String imageUrl) {
    _ws.send(
      '/app/chat.send',
      jsonEncode({'roomId': int.parse(roomId), 'content': imageUrl, 'type': 'IMAGE'}),
    );
  }

  void sendTyping(String roomId, bool isTyping) {
    _ws.sendTyping(roomId, isTyping);
  }

  void subscribeRoom(String roomId, void Function(MessageResponse) onMessage) {
    _ws.subscribeChat(roomId, (body) {
      try {
        final msg =
            MessageResponse.fromJson(jsonDecode(body) as Map<String, dynamic>);
        onMessage(msg);
      } catch (e) {
        debugPrint('[ChatRepo] subscribeRoom parse error: $e');
      }
    });
  }

  void unsubscribeRoom(String roomId) {
    _ws.unsubscribeChat(roomId);
  }

  void subscribeNewRooms(void Function(ChatRoomResponse) onRoom) {
    _ws.subscribeNewRooms((body) {
      try {
        final room =
            ChatRoomResponse.fromJson(jsonDecode(body) as Map<String, dynamic>);
        onRoom(room);
      } catch (e) {
        debugPrint('[ChatRepo] subscribeNewRooms parse error: $e');
      }
    });
  }

  void subscribeRoomClaimed(
      String roomId, void Function(ChatRoomResponse) onClaimed) {
    _ws.subscribeRoomClaimed(roomId, (body) {
      try {
        final room =
            ChatRoomResponse.fromJson(jsonDecode(body) as Map<String, dynamic>);
        onClaimed(room);
      } catch (e) {
        debugPrint('[ChatRepo] subscribeRoomClaimed parse error: $e');
      }
    });
  }

  Map<String, dynamic> _unwrap(dynamic json) {
    if (json is Map<String, dynamic>) {
      return json['data'] as Map<String, dynamic>? ?? json;
    }
    return json as Map<String, dynamic>;
  }
}
