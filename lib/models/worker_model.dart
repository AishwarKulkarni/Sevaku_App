import 'package:json_annotation/json_annotation.dart';
import 'package:workzy/models/user_model.dart';

part 'worker_model.g.dart';

String _stringFromJson(dynamic value) => value as String? ?? '';

@JsonSerializable(fieldRename: FieldRename.snake)
class WorkerModel extends UserModel {
  @JsonKey(fromJson: _stringFromJson)
  final String category;
  
  @JsonKey(fromJson: _stringFromJson)
  final String bio;
  final List<String> skills;
  final List<String> portfolioImages;
  final double hourlyRate;
  final double rating;
  final int reviewCount;
  final bool isAvailable;
  final List<String> serviceAreas;
  final Map<String, dynamic> availability;
  final int jobsCompleted;

  const WorkerModel({
    @JsonKey(name: 'id') required super.uid,
    required super.name,
    required super.email,
    required super.phone,
    required super.photoUrl,
    required super.city,
    super.fcmToken,
    required super.createdAt,
    required this.category,
    required this.bio,
    required this.skills,
    required this.portfolioImages,
    required this.hourlyRate,
    required this.rating,
    required this.reviewCount,
    required this.isAvailable,
    required this.serviceAreas,
    required this.availability,
    this.jobsCompleted = 0,
  }) : super(role: 'worker');

  factory WorkerModel.fromJson(Map<String, dynamic> json) => _$WorkerModelFromJson(json);
  
  @override
  Map<String, dynamic> toJson() => _$WorkerModelToJson(this);

  // Keep these for backward compatibility during migration
  @override
  Map<String, dynamic> toMap() => toJson();
  
  factory WorkerModel.fromMap(Map<String, dynamic> map) {
    try {
      return WorkerModel.fromJson(map);
    } catch (e) {
      // Fallback
      return WorkerModel(
        uid: map['uid'] ?? map['id'] ?? '',
        name: map['name'] ?? '',
        email: map['email'] ?? '',
        phone: map['phone'] ?? '',
        photoUrl: map['photoUrl'] ?? map['photo_url'] ?? '',
        city: map['city'] ?? '',
        fcmToken: map['fcmToken'] ?? map['fcm_token'],
        createdAt: map['createdAt'] != null 
            ? DateTime.tryParse(map['createdAt'].toString()) ?? DateTime.now()
            : (map['created_at'] != null 
                ? DateTime.tryParse(map['created_at'].toString()) ?? DateTime.now() 
                : DateTime.now()),
        category: map['category'] ?? '',
        bio: map['bio'] ?? '',
        skills: List<String>.from(map['skills'] ?? []),
        portfolioImages: List<String>.from(map['portfolioImages'] ?? map['portfolio_images'] ?? []),
        hourlyRate: (map['hourlyRate'] ?? map['hourly_rate'] ?? 0).toDouble(),
        rating: (map['rating'] ?? 0).toDouble(),
        reviewCount: map['reviewCount'] ?? map['review_count'] ?? 0,
        isAvailable: map['isAvailable'] ?? map['is_available'] ?? true,
        serviceAreas: List<String>.from(map['serviceAreas'] ?? map['service_areas'] ?? []),
        availability: Map<String, dynamic>.from(map['availability'] ?? {}),
        jobsCompleted: map['jobsCompleted'] ?? map['jobs_completed'] ?? 0,
      );
    }
  }
}

