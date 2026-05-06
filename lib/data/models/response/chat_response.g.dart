// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MessageResponse _$MessageResponseFromJson(Map<String, dynamic> json) =>
    MessageResponse(
      id: (json['id'] as num).toInt(),
      senderId: (json['senderId'] as num).toInt(),
      content: json['content'] as String,
      type: json['type'] as String,
      isRead: json['isRead'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$MessageResponseToJson(MessageResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'senderId': instance.senderId,
      'content': instance.content,
      'type': instance.type,
      'isRead': instance.isRead,
      'createdAt': instance.createdAt.toIso8601String(),
    };

ChatRoomResponse _$ChatRoomResponseFromJson(Map<String, dynamic> json) =>
    ChatRoomResponse(
      id: (json['id'] as num).toInt(),
      customerId: (json['customerId'] as num).toInt(),
      staffId: (json['staffId'] as num).toInt(),
      staffName: json['staffName'] as String,
      staffAvatar: json['staffAvatar'] as String?,
      lastMessage: json['lastMessage'] == null
          ? null
          : MessageResponse.fromJson(
              json['lastMessage'] as Map<String, dynamic>,
            ),
      unreadCount: (json['unreadCount'] as num).toInt(),
    );

Map<String, dynamic> _$ChatRoomResponseToJson(ChatRoomResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'customerId': instance.customerId,
      'staffId': instance.staffId,
      'staffName': instance.staffName,
      'staffAvatar': instance.staffAvatar,
      'lastMessage': instance.lastMessage,
      'unreadCount': instance.unreadCount,
    };
