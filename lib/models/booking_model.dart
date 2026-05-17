import 'package:json_annotation/json_annotation.dart';

part 'booking_model.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class BookingModel {
  final String id;
  final String customerId;
  final String customerName;
  final String? customerPhoto;
  final String workerId;
  final String workerName;
  final String? workerPhoto;
  final String category;
  final String description;
  final String status; // pending, accepted, in_progress, completed, cancelled
  final DateTime scheduledDate;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final double totalAmount;
  final String paymentStatus; // pending, paid, failed, refunded
  final String? address;

  const BookingModel({
    required this.id,
    required this.customerId,
    required this.customerName,
    this.customerPhoto,
    required this.workerId,
    required this.workerName,
    this.workerPhoto,
    required this.category,
    required this.description,
    required this.status,
    required this.scheduledDate,
    required this.createdAt,
    this.updatedAt,
    required this.totalAmount,
    required this.paymentStatus,
    this.address,
  });

  BookingModel copyWith({
    String? status,
    String? paymentStatus,
  }) {
    return BookingModel(
      id: id,
      customerId: customerId,
      customerName: customerName,
      customerPhoto: customerPhoto,
      workerId: workerId,
      workerName: workerName,
      workerPhoto: workerPhoto,
      category: category,
      description: description,
      status: status ?? this.status,
      scheduledDate: scheduledDate,
      createdAt: createdAt,
      updatedAt: updatedAt,
      totalAmount: totalAmount,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      address: address,
    );
  }

  factory BookingModel.fromJson(Map<String, dynamic> json) => _$BookingModelFromJson(json);
  
  Map<String, dynamic> toJson() => _$BookingModelToJson(this);

  // Keep these for backward compatibility during migration
  Map<String, dynamic> toMap() => toJson();
  
  factory BookingModel.fromMap(Map<String, dynamic> map) {
    try {
      return BookingModel.fromJson(map);
    } catch (e) {
      // Fallback
      return BookingModel(
        id: map['id'] ?? '',
        customerId: map['customerId'] ?? map['customer_id'] ?? '',
        customerName: map['customerName'] ?? map['customer_name'] ?? '',
        customerPhoto: map['customerPhoto'] ?? map['customer_photo'],
        workerId: map['workerId'] ?? map['worker_id'] ?? '',
        workerName: map['workerName'] ?? map['worker_name'] ?? '',
        workerPhoto: map['workerPhoto'] ?? map['worker_photo'],
        category: map['category'] ?? '',
        description: map['description'] ?? '',
        status: map['status'] ?? 'pending',
        scheduledDate: map['scheduledDate'] != null 
            ? DateTime.tryParse(map['scheduledDate'].toString()) ?? DateTime.now()
            : (map['scheduled_date'] != null 
                ? DateTime.tryParse(map['scheduled_date'].toString()) ?? DateTime.now() 
                : DateTime.now()),
        createdAt: map['createdAt'] != null 
            ? DateTime.tryParse(map['createdAt'].toString()) ?? DateTime.now()
            : (map['created_at'] != null 
                ? DateTime.tryParse(map['created_at'].toString()) ?? DateTime.now() 
                : DateTime.now()),
        totalAmount: (map['totalAmount'] ?? map['total_amount'] ?? 0).toDouble(),
        paymentStatus: map['paymentStatus'] ?? map['payment_status'] ?? 'pending',
        address: map['address'],
      );
    }
  }
}

