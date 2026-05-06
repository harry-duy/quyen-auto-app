import 'package:json_annotation/json_annotation.dart';
part 'chat_response.g.dart';

@JsonSerializable()
class MessageResponse {
  final int      id;
  final int      senderId;
  final String   content;
  final String   type;      // text | image | file
  final bool     isRead;
  final DateTime createdAt;

  const MessageResponse({
    required this.id,
    required this.senderId,
    required this.content,
    required this.type,
    required this.isRead,
    required this.createdAt,
  });

  factory MessageResponse.fromJson(Map<String, dynamic> json) =>
      _$MessageResponseFromJson(json);
  Map<String, dynamic> toJson() => _$MessageResponseToJson(this);
}

@JsonSerializable()
class ChatRoomResponse {
  final int              id;
  final int              customerId;
  final int              staffId;
  final String           staffName;
  final String?          staffAvatar;
  final MessageResponse? lastMessage;
  final int              unreadCount;

  const ChatRoomResponse({
    required this.id,
    required this.customerId,
    required this.staffId,
    required this.staffName,
    this.staffAvatar,
    this.lastMessage,
    required this.unreadCount,
  });

  factory ChatRoomResponse.fromJson(Map<String, dynamic> json) =>
      _$ChatRoomResponseFromJson(json);
  Map<String, dynamic> toJson() => _$ChatRoomResponseToJson(this);
}
