import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sevaku/router/app_router.dart';
import 'package:sevaku/services/api_service.dart';

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
    // Show an in-app notification (snackbar)
    final context = rootNavigatorKey.currentContext;
    if (context != null && message.notification != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message.notification!.title ?? 'New Notification'),
          action: SnackBarAction(
            label: 'Dismiss',
            onPressed: () {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
            },
          ),
        ),
      );
    }
  }

  void _handleBackgroundMessage(RemoteMessage message) {
    // Navigate to the relevant screen based on message data
    final context = rootNavigatorKey.currentContext;
    if (context != null && message.data.containsKey('route')) {
      final route = message.data['route'] as String;
      context.go(route);
    } else {
      // Fallback action or just logging
      // ignore: avoid_print
      print('Background message opened, no route provided: ${message.data}');
    }
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
