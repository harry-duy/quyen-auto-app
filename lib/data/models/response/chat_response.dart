import 'package:json_annotation/json_annotation.dart';
part 'chat_response.g.dart';

@JsonSerializable()
class MessageResponse {
  final int      id;
  final int      roomId;
  final int      senderId;
  final String   senderName;
  final String?  senderAvatar;
  final String   content;
  final String   type;      // TEXT | IMAGE | FILE
  final bool     isRead;
  final DateTime createdAt;

  const MessageResponse({
    required this.id,
    required this.roomId,
    required this.senderId,
    required this.senderName,
    this.senderAvatar,
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
  final int       id;
  final int       customerId;
  final String?   customerName;
  final String?   customerAvatar;
  final int       staffId;
  final String    staffName;
  final String?   staffAvatar;
  final String?   lastMessage;
  final DateTime? lastMessageAt;
  final int       unreadCount;

  const ChatRoomResponse({
    required this.id,
    required this.customerId,
    this.customerName,
    this.customerAvatar,
    required this.staffId,
    required this.staffName,
    this.staffAvatar,
    this.lastMessage,
    this.lastMessageAt,
    required this.unreadCount,
  });

  factory ChatRoomResponse.fromJson(Map<String, dynamic> json) =>
      _$ChatRoomResponseFromJson(json);
  Map<String, dynamic> toJson() => _$ChatRoomResponseToJson(this);
}
