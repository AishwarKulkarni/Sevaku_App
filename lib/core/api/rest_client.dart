import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import '../../models/user_model.dart';
import '../../models/worker_model.dart';
import '../../models/booking_model.dart';
import '../../models/review_model.dart';
import '../../models/chat_model.dart';

part 'rest_client.g.dart';

@RestApi()
abstract class RestClient {
  factory RestClient(Dio dio, {String baseUrl}) = _RestClient;

  // Auth
  @POST('/auth/register')
  Future<AuthResponse> register(@Body() Map<String, dynamic> body);

  @POST('/auth/login')
  Future<AuthResponse> login(@Body() Map<String, dynamic> body);

  @GET('/auth/me')
  Future<UserModel> getMe();

  // Workers
  @GET('/workers')
  Future<List<WorkerModel>> getWorkers({
    @Query('category') String? category,
    @Query('query') String? query,
    @Query('is_available') bool? isAvailable,
  });

  @GET('/workers/{worker_id}')
  Future<WorkerModel> getWorker(@Path('worker_id') String workerId);

  // Bookings
  @POST('/bookings')
  Future<BookingModel> createBooking(@Body() Map<String, dynamic> body);

  @GET('/bookings')
  Future<List<BookingModel>> getBookings({@Query('status') String? status});

  @PATCH('/bookings/{booking_id}/status')
  Future<BookingModel> updateBookingStatus(
    @Path('booking_id') String bookingId,
    @Body() Map<String, dynamic> body,
  );

  @PATCH('/bookings/{booking_id}/payment')
  Future<BookingModel> updatePaymentStatus(
    @Path('booking_id') String bookingId,
    @Body() Map<String, dynamic> body,
  );

  // Reviews
  @POST('/reviews')
  Future<ReviewModel> createReview(@Body() Map<String, dynamic> body);

  @GET('/reviews/worker/{worker_id}')
  Future<List<ReviewModel>> getWorkerReviews(
    @Path('worker_id') String workerId,
  );

  // Chat
  @GET('/chat')
  Future<List<ChatModel>> getChats();

  @POST('/chat/with/{other_user_id}')
  Future<ChatModel> getOrCreateChat(@Path('other_user_id') String otherUserId);

  @GET('/chat/{chat_id}/messages')
  Future<List<MessageModel>> getChatMessages(@Path('chat_id') String chatId);

  @POST('/chat/{chat_id}/messages')
  Future<MessageModel> sendMessage(
    @Path('chat_id') String chatId,
    @Body() Map<String, dynamic> body,
  );

  // Users
  @PATCH('/users/me')
  Future<UserModel> updateUser(@Body() Map<String, dynamic> body);

  // Worker profile updates
  @PATCH('/workers/me/profile')
  Future<WorkerModel> updateWorkerProfile(@Body() Map<String, dynamic> body);
}

// Temporary class for AuthResponse, we will move this to models later if needed

class AuthResponse {
  final String accessToken;
  final String refreshToken;
  final UserModel user;

  AuthResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      accessToken: json['access_token'],
      refreshToken: json['refresh_token'],
      user: UserModel.fromJson(json['user']),
    );
  }
}
