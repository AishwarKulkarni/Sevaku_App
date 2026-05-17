// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'review_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReviewModel _$ReviewModelFromJson(Map<String, dynamic> json) => ReviewModel(
  id: json['id'] as String,
  bookingId: json['booking_id'] as String,
  reviewerId: json['reviewer_id'] as String,
  reviewerName: json['reviewer_name'] as String,
  reviewerPhoto: json['reviewer_photo'] as String?,
  revieweeId: json['reviewee_id'] as String,
  rating: (json['rating'] as num).toDouble(),
  comment: json['comment'] as String,
  createdAt: DateTime.parse(json['created_at'] as String),
);

Map<String, dynamic> _$ReviewModelToJson(ReviewModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'booking_id': instance.bookingId,
      'reviewer_id': instance.reviewerId,
      'reviewer_name': instance.reviewerName,
      'reviewer_photo': instance.reviewerPhoto,
      'reviewee_id': instance.revieweeId,
      'rating': instance.rating,
      'comment': instance.comment,
      'created_at': instance.createdAt.toIso8601String(),
    };
