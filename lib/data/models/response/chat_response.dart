import 'package:json_annotation/json_annotation.dart';
part 'chat_response.g.dart';

@JsonSerializable()
class MessageResponse {
  final int id;
  final int senderId;
  final String senderName;
  final String? senderAvatar;
  final String content;
  final String type;
  final bool isRead;
  final DateTime createdAt;

  const MessageResponse({
    required this.id,
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
  final int id;
  final int customerId;
  final String customerName;
  final String? customerAvatar;
  final int? staffId;
  final String? staffName;
  final String? staffAvatar;
  final String? orderCode;
  final bool isWaiting;
  final String? lastMessage;
  final DateTime? lastMessageAt;
  final int unreadCount;

  const ChatRoomResponse({
    required this.id,
    required this.customerId,
    required this.customerName,
    this.customerAvatar,
    this.staffId,
    this.staffName,
    this.staffAvatar,
    this.orderCode,
    required this.isWaiting,
    this.lastMessage,
    this.lastMessageAt,
    required this.unreadCount,
  });

  factory ChatRoomResponse.fromJson(Map<String, dynamic> json) =>
      _$ChatRoomResponseFromJson(json);
  Map<String, dynamic> toJson() => _$ChatRoomResponseToJson(this);
}
