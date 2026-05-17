// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChatModel _$ChatModelFromJson(Map<String, dynamic> json) => ChatModel(
  id: json['id'] as String,
  participant1Id: json['participant_1_id'] as String,
  participant2Id: json['participant_2_id'] as String,
  lastMessage: json['last_message'] as String?,
  lastMessageTime: json['last_message_time'] == null
      ? null
      : DateTime.parse(json['last_message_time'] as String),
  participantNames: Map<String, String?>.from(json['participant_names'] as Map),
  participantPhotos: Map<String, String?>.from(
    json['participant_photos'] as Map,
  ),
  unreadCount: (json['unread_count'] as num?)?.toInt() ?? 0,
  createdAt: DateTime.parse(json['created_at'] as String),
);

Map<String, dynamic> _$ChatModelToJson(ChatModel instance) => <String, dynamic>{
  'id': instance.id,
  'participant_1_id': instance.participant1Id,
  'participant_2_id': instance.participant2Id,
  'last_message': instance.lastMessage,
  'last_message_time': instance.lastMessageTime?.toIso8601String(),
  'participant_names': instance.participantNames,
  'participant_photos': instance.participantPhotos,
  'unread_count': instance.unreadCount,
  'created_at': instance.createdAt.toIso8601String(),
};

MessageModel _$MessageModelFromJson(Map<String, dynamic> json) => MessageModel(
  id: json['id'] as String,
  senderId: json['sender_id'] as String,
  text: json['text'] as String,
  timestamp: DateTime.parse(json['timestamp'] as String),
  isRead: json['is_read'] as bool? ?? false,
);

Map<String, dynamic> _$MessageModelToJson(MessageModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'sender_id': instance.senderId,
      'text': instance.text,
      'timestamp': instance.timestamp.toIso8601String(),
      'is_read': instance.isRead,
    };
