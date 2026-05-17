import 'package:json_annotation/json_annotation.dart';

part 'chat_model.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class ChatModel {
  final String id;
  @JsonKey(name: 'participant_1_id')
  final String participant1Id;
  @JsonKey(name: 'participant_2_id')
  final String participant2Id;
  final String? lastMessage;
  final DateTime? lastMessageTime;
  final Map<String, String?> participantNames;   // uid -> displayName
  final Map<String, String?> participantPhotos;  // uid -> photoUrl
  final int unreadCount;
  final DateTime createdAt;

  const ChatModel({
    required this.id,
    required this.participant1Id,
    required this.participant2Id,
    this.lastMessage,
    this.lastMessageTime,
    required this.participantNames,
    required this.participantPhotos,
    this.unreadCount = 0,
    required this.createdAt,
  });

  DateTime get displayTime => lastMessageTime ?? createdAt;

  /// Returns the display name of the OTHER participant (not the current user).
  String otherName(String myUid) {
    final otherId = participant1Id != myUid ? participant1Id : participant2Id;
    return participantNames[otherId] ?? 'Unknown';
  }

  /// Returns the photo URL of the OTHER participant (not the current user).
  String otherPhoto(String myUid) {
    final otherId = participant1Id != myUid ? participant1Id : participant2Id;
    return participantPhotos[otherId] ?? '';
  }
  
  String otherId(String myUid) {
    return participant1Id != myUid ? participant1Id : participant2Id;
  }

  factory ChatModel.fromJson(Map<String, dynamic> json) => _$ChatModelFromJson(json);
  
  Map<String, dynamic> toJson() => _$ChatModelToJson(this);

  // Keep these for backward compatibility during migration
  Map<String, dynamic> toMap() => toJson();
  
  factory ChatModel.fromMap(Map<String, dynamic> map) {
    try {
      return ChatModel.fromJson(map);
    } catch (e) {
      // Fallback
      List<String> parts = List<String>.from(map['participants'] ?? []);
      return ChatModel(
        id: map['id'] ?? '',
        participant1Id: parts.isNotEmpty ? parts[0] : map['participant_1_id'] ?? '',
        participant2Id: parts.length > 1 ? parts[1] : map['participant_2_id'] ?? '',
        lastMessage: map['lastMessage'] ?? map['last_message'] ?? '',
        lastMessageTime: map['lastMessageTime'] != null 
            ? DateTime.tryParse(map['lastMessageTime'].toString())
            : (map['last_message_time'] != null 
                ? DateTime.tryParse(map['last_message_time'].toString()) 
                : null),
        participantNames: Map<String, String?>.from(map['participantNames'] ?? map['participant_names'] ?? {}),
        participantPhotos: Map<String, String?>.from(map['participantPhotos'] ?? map['participant_photos'] ?? {}),
        unreadCount: map['unreadCount'] ?? map['unread_count'] ?? 0,
        createdAt: map['createdAt'] != null 
            ? DateTime.tryParse(map['createdAt'].toString()) ?? DateTime.now()
            : (map['created_at'] != null 
                ? DateTime.tryParse(map['created_at'].toString()) ?? DateTime.now() 
                : DateTime.now()),
      );
    }
  }
}

@JsonSerializable(fieldRename: FieldRename.snake)
class MessageModel {
  final String id;
  final String senderId;
  final String text;
  final DateTime timestamp;
  final bool isRead;

  const MessageModel({
    required this.id,
    required this.senderId,
    required this.text,
    required this.timestamp,
    this.isRead = false,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) => _$MessageModelFromJson(json);
  
  Map<String, dynamic> toJson() => _$MessageModelToJson(this);

  // Keep these for backward compatibility during migration
  Map<String, dynamic> toMap() => toJson();
  
  factory MessageModel.fromMap(Map<String, dynamic> map) {
    try {
      return MessageModel.fromJson(map);
    } catch (e) {
      // Fallback
      return MessageModel(
        id: map['id'] ?? '',
        senderId: map['senderId'] ?? map['sender_id'] ?? '',
        text: map['text'] ?? '',
        timestamp: map['timestamp'] != null 
            ? DateTime.tryParse(map['timestamp'].toString()) ?? DateTime.now()
            : DateTime.now(),
        isRead: map['isRead'] ?? map['is_read'] ?? false,
      );
    }
  }
}

