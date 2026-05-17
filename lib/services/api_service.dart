import '../core/api/api_client.dart';
import '../core/api/rest_client.dart';
import '../models/user_model.dart';
import '../models/worker_model.dart';
import '../models/booking_model.dart';
import '../models/review_model.dart';
import '../models/chat_model.dart';

class ApiService {
  final RestClient _restClient;

  ApiService() : _restClient = RestClient(ApiClient().dio);

  // ─── USERS ───────────────────────────────────────────────────

  /// Get user by ID (Using /auth/me for current user, backend doesn't have public get user yet)
  Future<UserModel?> getUser(String uid) async {
    try {
      return await _restClient.getMe();
    } catch (e) {
      return null;
    }
  }

  // ─── WORKERS ─────────────────────────────────────────────────

  Future<WorkerModel?> getWorker(String uid) async {
    try {
      return await _restClient.getWorker(uid);
    } catch (e) {
      return null;
    }
  }

  Future<List<WorkerModel>> getWorkers({String? category}) async {
    try {
      if (category == 'all') category = null;
      return await _restClient.getWorkers(category: category);
    } catch (e) {
      return [];
    }
  }

  Future<List<WorkerModel>> getFeaturedWorkers({int limit = 10}) async {
    try {
      // Assuming backend returns sorted by rating. We just take first 10.
      final workers = await _restClient.getWorkers();
      workers.sort((a, b) => b.rating.compareTo(a.rating));
      return workers.take(limit).toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<WorkerModel>> searchWorkers(String query) async {
    try {
      return await _restClient.getWorkers(query: query);
    } catch (e) {
      return [];
    }
  }

  // ─── BOOKINGS ────────────────────────────────────────────────

  Future<void> createBooking(BookingModel booking) async {
    await _restClient.createBooking({
      'worker_id': booking.workerId,
      'category': booking.category,
      'description': booking.description,
      'scheduled_date': booking.scheduledDate.toIso8601String(),
      'total_amount': booking.totalAmount,
      'address': booking.address,
    });
  }

  Future<List<BookingModel>> getBookings({String? status}) async {
    try {
      return await _restClient.getBookings(status: status);
    } catch (e) {
      return [];
    }
  }

  // ─── REVIEWS ─────────────────────────────────────────────────

  Future<void> addReview(ReviewModel review) async {
    await _restClient.createReview({
      'booking_id': review.bookingId,
      'rating': review.rating,
      'comment': review.comment,
    });
  }

  Future<List<ReviewModel>> getWorkerReviews(String workerId) async {
    try {
      return await _restClient.getWorkerReviews(workerId);
    } catch (e) {
      return [];
    }
  }

  // ─── CHAT ────────────────────────────────────────────────────

  Future<List<ChatModel>> getUserChats() async {
    try {
      return await _restClient.getChats();
    } catch (e) {
      return [];
    }
  }

  Future<List<MessageModel>> getChatMessages(String chatId) async {
    try {
      return await _restClient.getChatMessages(chatId);
    } catch (e) {
      return [];
    }
  }

  Future<String> getOrCreateChat(
    String currentUserId,
    String otherUserId,
    String? otherName,
    String? otherPhoto, {
    String? user1Name = '',
    String? user1Photo = '',
  }) async {
    try {
      final chat = await _restClient.getOrCreateChat(otherUserId);
      return chat.id;
    } catch (e) {
      print('Error in getOrCreateChat: $e');
      throw Exception('Failed to get or create chat: $e');
    }
  }

  Future<void> sendMessage(String chatId, MessageModel message) async {
    try {
      await _restClient.sendMessage(chatId, {
        'text': message.text,
      });
    } catch (e) {
      print('Failed to send message: $e');
      rethrow;
    }
  }

  // ─── UPDATES ─────────────────────────────────────────────────

  Future<void> updateBookingStatus(String bookingId, String status) async {
    try {
      await _restClient.updateBookingStatus(bookingId, {'status': status});
    } catch (e) {
      print('Failed to update booking status: $e');
    }
  }

  Future<void> updatePaymentStatus(
    String bookingId,
    String paymentStatus,
  ) async {
    try {
      await _restClient.updatePaymentStatus(bookingId, {
        'payment_status': paymentStatus,
      });
    } catch (e) {
      print('Failed to update payment status: $e');
    }
  }

  Future<void> updateUser(String uid, Map<String, dynamic> data) async {
    try {
      await _restClient.updateUser(data);
    } catch (e) {
      print('Failed to update user: $e');
    }
  }

  Future<void> updateWorkerProfile(
    String uid,
    Map<String, dynamic> data,
  ) async {
    try {
      await _restClient.updateWorkerProfile(data);
    } catch (e) {
      print('Failed to update worker profile: $e');
    }
  }

  Future<void> updateFcmToken(String uid, String token) async {
    try {
      await _restClient.updateUser({'fcm_token': token});
    } catch (e) {
      print('Failed to update FCM token: $e');
    }
  }
}
