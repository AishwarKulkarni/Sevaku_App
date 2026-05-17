// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'worker_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WorkerModel _$WorkerModelFromJson(Map<String, dynamic> json) => WorkerModel(
  uid: json['id'] as String,
  name: json['name'] as String,
  email: json['email'] as String,
  phone: _stringFromJson(json['phone']),
  photoUrl: _stringFromJson(json['photo_url']),
  city: _stringFromJson(json['city']),
  fcmToken: json['fcm_token'] as String?,
  createdAt: DateTime.parse(json['created_at'] as String),
  category: _stringFromJson(json['category']),
  bio: _stringFromJson(json['bio']),
  skills: (json['skills'] as List<dynamic>).map((e) => e as String).toList(),
  portfolioImages: (json['portfolio_images'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  hourlyRate: (json['hourly_rate'] as num).toDouble(),
  rating: (json['rating'] as num).toDouble(),
  reviewCount: (json['review_count'] as num).toInt(),
  isAvailable: json['is_available'] as bool,
  serviceAreas: (json['service_areas'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  availability: json['availability'] as Map<String, dynamic>,
  jobsCompleted: (json['jobs_completed'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$WorkerModelToJson(WorkerModel instance) =>
    <String, dynamic>{
      'id': instance.uid,
      'name': instance.name,
      'email': instance.email,
      'phone': instance.phone,
      'photo_url': instance.photoUrl,
      'city': instance.city,
      'fcm_token': instance.fcmToken,
      'created_at': instance.createdAt.toIso8601String(),
      'category': instance.category,
      'bio': instance.bio,
      'skills': instance.skills,
      'portfolio_images': instance.portfolioImages,
      'hourly_rate': instance.hourlyRate,
      'rating': instance.rating,
      'review_count': instance.reviewCount,
      'is_available': instance.isAvailable,
      'service_areas': instance.serviceAreas,
      'availability': instance.availability,
      'jobs_completed': instance.jobsCompleted,
    };
