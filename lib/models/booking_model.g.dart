// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'booking_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BookingModel _$BookingModelFromJson(Map<String, dynamic> json) => BookingModel(
  id: json['id'] as String,
  customerId: json['customer_id'] as String,
  customerName: json['customer_name'] as String,
  customerPhoto: json['customer_photo'] as String?,
  workerId: json['worker_id'] as String,
  workerName: json['worker_name'] as String,
  workerPhoto: json['worker_photo'] as String?,
  category: json['category'] as String,
  description: json['description'] as String,
  status: json['status'] as String,
  scheduledDate: DateTime.parse(json['scheduled_date'] as String),
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: json['updated_at'] == null
      ? null
      : DateTime.parse(json['updated_at'] as String),
  totalAmount: (json['total_amount'] as num).toDouble(),
  paymentStatus: json['payment_status'] as String,
  address: json['address'] as String?,
);

Map<String, dynamic> _$BookingModelToJson(BookingModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'customer_id': instance.customerId,
      'customer_name': instance.customerName,
      'customer_photo': instance.customerPhoto,
      'worker_id': instance.workerId,
      'worker_name': instance.workerName,
      'worker_photo': instance.workerPhoto,
      'category': instance.category,
      'description': instance.description,
      'status': instance.status,
      'scheduled_date': instance.scheduledDate.toIso8601String(),
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
      'total_amount': instance.totalAmount,
      'payment_status': instance.paymentStatus,
      'address': instance.address,
    };
