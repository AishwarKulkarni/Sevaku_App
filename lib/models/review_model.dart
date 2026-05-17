import 'package:json_annotation/json_annotation.dart';

part 'review_model.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class ReviewModel {
  final String id;
  final String bookingId;
  final String reviewerId;
  final String reviewerName;
  final String? reviewerPhoto;
  final String revieweeId;
  final double rating;
  final String comment;
  final DateTime createdAt;

  const ReviewModel({
    required this.id,
    required this.bookingId,
    required this.reviewerId,
    required this.reviewerName,
    this.reviewerPhoto,
    required this.revieweeId,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) => _$ReviewModelFromJson(json);
  
  Map<String, dynamic> toJson() => _$ReviewModelToJson(this);

  // Keep these for backward compatibility during migration
  Map<String, dynamic> toMap() => toJson();
  
  factory ReviewModel.fromMap(Map<String, dynamic> map) {
    try {
      return ReviewModel.fromJson(map);
    } catch (e) {
      // Fallback
      return ReviewModel(
        id: map['id'] ?? '',
        bookingId: map['bookingId'] ?? map['booking_id'] ?? '',
        reviewerId: map['reviewerId'] ?? map['reviewer_id'] ?? '',
        reviewerName: map['reviewerName'] ?? map['reviewer_name'] ?? '',
        reviewerPhoto: map['reviewerPhoto'] ?? map['reviewer_photo'],
        revieweeId: map['revieweeId'] ?? map['reviewee_id'] ?? '',
        rating: (map['rating'] ?? 0).toDouble(),
        comment: map['comment'] ?? '',
        createdAt: map['createdAt'] != null 
            ? DateTime.tryParse(map['createdAt'].toString()) ?? DateTime.now()
            : (map['created_at'] != null 
                ? DateTime.tryParse(map['created_at'].toString()) ?? DateTime.now() 
                : DateTime.now()),
      );
    }
  }
}

