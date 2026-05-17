import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart';

String _stringFromJson(dynamic value) => value as String? ?? '';

@JsonSerializable(fieldRename: FieldRename.snake)
class UserModel {
  @JsonKey(name: 'id')
  final String uid;
  final String name;
  final String email;
  
  @JsonKey(fromJson: _stringFromJson)
  final String phone;
  
  @JsonKey(fromJson: _stringFromJson)
  final String photoUrl;
  
  final String role; // 'customer' or 'worker'
  
  @JsonKey(fromJson: _stringFromJson)
  final String city;
  
  final String? fcmToken;
  final DateTime createdAt;

  const UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.phone,
    required this.photoUrl,
    required this.role,
    required this.city,
    this.fcmToken,
    required this.createdAt,
  });

  UserModel copyWith({
    String? uid,
    String? name,
    String? email,
    String? phone,
    String? photoUrl,
    String? role,
    String? city,
    String? fcmToken,
    DateTime? createdAt,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      photoUrl: photoUrl ?? this.photoUrl,
      role: role ?? this.role,
      city: city ?? this.city,
      fcmToken: fcmToken ?? this.fcmToken,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory UserModel.fromJson(Map<String, dynamic> json) => _$UserModelFromJson(json);
  
  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  // Keep these for backward compatibility during migration
  Map<String, dynamic> toMap() => toJson();
  factory UserModel.fromMap(Map<String, dynamic> map) {
    // Map Firestore camelCase/string dates to what fromJson expects temporarily if needed
    // or simply just redirect
    try {
      return UserModel.fromJson(map);
    } catch (e) {
      // Fallback for old firestore data mapping during transition
      return UserModel(
        uid: map['uid'] ?? map['id'] ?? '',
        name: map['name'] ?? '',
        email: map['email'] ?? '',
        phone: map['phone'] ?? '',
        photoUrl: map['photoUrl'] ?? map['photo_url'] ?? '',
        role: map['role'] ?? 'customer',
        city: map['city'] ?? '',
        fcmToken: map['fcmToken'] ?? map['fcm_token'],
        createdAt: map['createdAt'] != null 
            ? DateTime.tryParse(map['createdAt'].toString()) ?? DateTime.now()
            : (map['created_at'] != null 
                ? DateTime.tryParse(map['created_at'].toString()) ?? DateTime.now() 
                : DateTime.now()),
      );
    }
  }
}

