import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workzy/features/auth/providers/auth_provider.dart';
import 'package:workzy/models/booking_model.dart';
import 'package:workzy/models/chat_model.dart';
import 'package:workzy/models/review_model.dart';
import 'package:workzy/models/worker_model.dart';

// ─── Workers ────────────────────────────────────────────────────────────

/// Future of top-rated available workers
final featuredWorkersProvider = FutureProvider.autoDispose<List<WorkerModel>>((
  ref,
) {
  final api = ref.watch(apiServiceProvider);
  return api.getFeaturedWorkers();
});

/// Future of all workers or filtered by category
final workersByCategoryProvider = FutureProvider.autoDispose
    .family<List<WorkerModel>, String?>((ref, category) {
      final api = ref.watch(apiServiceProvider);
      return api.getWorkers(category: category);
    });

/// Future provider to fetch a single worker profile
final workerProfileProvider = FutureProvider.autoDispose
    .family<WorkerModel?, String>((ref, workerId) {
      final api = ref.watch(apiServiceProvider);
      return api.getWorker(workerId);
    });

// ─── Bookings ───────────────────────────────────────────────────────────

/// Future of all bookings for the currently logged-in customer
final customerBookingsProvider = FutureProvider.autoDispose<List<BookingModel>>(
  (ref) {
    final api = ref.watch(apiServiceProvider);
    return api.getBookings();
  },
);

final workerBookingsProvider = FutureProvider.autoDispose<List<BookingModel>>((
  ref,
) {
  final api = ref.watch(apiServiceProvider);
  return api.getBookings();
});

// ─── Chat ───────────────────────────────────────────────────────────────

/// Future of chat threads for the current user
final userChatsProvider = FutureProvider.autoDispose<List<ChatModel>>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return [];

  final api = ref.watch(apiServiceProvider);
  return api.getUserChats();
});

/// Future of messages in a specific chat room
final chatMessagesProvider = FutureProvider.autoDispose
    .family<List<MessageModel>, String>((ref, chatId) {
      final api = ref.watch(apiServiceProvider);
      return api.getChatMessages(chatId);
    });

// ─── Reviews ────────────────────────────────────────────────────────────

/// Future of reviews for a specific worker
final workerReviewsProvider = FutureProvider.autoDispose
    .family<List<ReviewModel>, String>((ref, workerId) {
      final api = ref.watch(apiServiceProvider);
      return api.getWorkerReviews(workerId);
    });
