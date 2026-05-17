import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:workzy/services/api_service.dart';

class NotificationService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final ApiService _apiService = ApiService();

  /// Initialize notifications and request permission
  Future<void> initialize(String userId) async {
    // Request permission (iOS)
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      // Get and save FCM token
      final token = await _messaging.getToken();
      if (token != null) {
        await _apiService.updateFcmToken(userId, token);
      }

      // Listen for token refresh
      _messaging.onTokenRefresh.listen((newToken) {
        _apiService.updateFcmToken(userId, newToken);
      });
    }

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handle background messages (when app is in background)
    FirebaseMessaging.onMessageOpenedApp.listen(_handleBackgroundMessage);
  }

  void _handleForegroundMessage(RemoteMessage message) {
    // TODO: Show an in-app notification (snackbar, overlay, etc.)
    // ignore: avoid_print
    print('Foreground message: ${message.notification?.title}');
  }

  void _handleBackgroundMessage(RemoteMessage message) {
    // TODO: Navigate to the relevant screen based on message data
    // ignore: avoid_print
    print('Background message opened: ${message.data}');
  }

  /// Subscribe to a topic (e.g., booking updates)
  Future<void> subscribeToTopic(String topic) async {
    await _messaging.subscribeToTopic(topic);
  }

  /// Unsubscribe from a topic
  Future<void> unsubscribeFromTopic(String topic) async {
    await _messaging.unsubscribeFromTopic(topic);
  }
}
