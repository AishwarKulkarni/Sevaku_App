// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserModel _$UserModelFromJson(Map<String, dynamic> json) => UserModel(
  uid: json['id'] as String,
  name: json['name'] as String,
  email: json['email'] as String,
  phone: _stringFromJson(json['phone']),
  photoUrl: _stringFromJson(json['photo_url']),
  role: json['role'] as String,
  city: _stringFromJson(json['city']),
  fcmToken: json['fcm_token'] as String?,
  createdAt: DateTime.parse(json['created_at'] as String),
);

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
  'id': instance.uid,
  'name': instance.name,
  'email': instance.email,
  'phone': instance.phone,
  'photo_url': instance.photoUrl,
  'role': instance.role,
  'city': instance.city,
  'fcm_token': instance.fcmToken,
  'created_at': instance.createdAt.toIso8601String(),
};
