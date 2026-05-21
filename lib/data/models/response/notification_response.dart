import 'package:json_annotation/json_annotation.dart';
part 'notification_response.g.dart';

@JsonSerializable()
class NotificationResponse {
  final int      id;
  final String   title;
  final String   body;
  final String   type;
  final String?  refId;
  final bool     isRead;
  final DateTime createdAt;

  const NotificationResponse({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    this.refId,
    required this.isRead,
    required this.createdAt,
  });

  factory NotificationResponse.fromJson(Map<String, dynamic> json) =>
      _$NotificationResponseFromJson(json);
  Map<String, dynamic> toJson() => _$NotificationResponseToJson(this);
}
