import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../model/notification_model.dart';
import '../repository/notifications_repository.dart';

/// Top-level handler required by Firebase for background messages.
/// Must be a top-level function (not a class method).
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Background messages are handled silently here.
  // The system tray notification is shown automatically by Firebase on Android.
  debugPrint('=== BACKGROUND NOTIFICATION: ${message.notification?.title} ===');
}

/// Service responsible for all push notification interactions.
/// Isolates platform SDKs (Firebase, FlutterLocalNotifications) from the rest of the app.
class PushNotificationService {
  late final FirebaseMessaging _firebaseMessaging;
  final FlutterLocalNotificationsPlugin _localNotifications;
  final NotificationsRepository _repository;

  /// Stream that broadcasts newly received [NotificationModel] to listeners (e.g., ViewModel).
  final StreamController<NotificationModel> _notificationStreamController =
      StreamController<NotificationModel>.broadcast();

  Stream<NotificationModel> get onNotificationReceived =>
      _notificationStreamController.stream;

  PushNotificationService({
    FlutterLocalNotificationsPlugin? localNotifications,
    NotificationsRepository? repository,
  })  : _localNotifications = localNotifications ?? FlutterLocalNotificationsPlugin(),
        _repository = repository ?? NotificationsRepository();

  /// Initializes the service: requests permissions, sets up local notifications,
  /// registers FCM token, and starts listening to message streams.
  Future<void> initialize() async {
    _firebaseMessaging = FirebaseMessaging.instance;
    await _setupLocalNotifications();
    await _requestPermissions();
    await _registerToken();
    _listenToForegroundMessages();
    _listenToNotificationTaps();
  }

  /// Disposes resources when the service is no longer needed.
  void dispose() {
    _notificationStreamController.close();
  }

  // ────────────────────────────────────────────────────
  // Topic Management (Categories)
  // ────────────────────────────────────────────────────

  /// Subscribes the device to a specific FCM topic (e.g., category_102)
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _firebaseMessaging.subscribeToTopic(topic);
      debugPrint('=== FCM: SUBSCRIBED TO TOPIC: $topic ===');
    } catch (e) {
      debugPrint('=== FCM: TOPIC SUBSCRIBE ERROR ($topic): $e ===');
    }
  }

  /// Unsubscribes the device from a specific FCM topic
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _firebaseMessaging.unsubscribeFromTopic(topic);
      debugPrint('=== FCM: UNSUBSCRIBED FROM TOPIC: $topic ===');
    } catch (e) {
      debugPrint('=== FCM: TOPIC UNSUBSCRIBE ERROR ($topic): $e ===');
    }
  }

  // ────────────────────────────────────────────────────
  // Private Methods
  // ────────────────────────────────────────────────────

  Future<void> _setupLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (response) {
        debugPrint('=== LOCAL NOTIFICATION TAPPED: ${response.payload} ===');
      },
    );

    // Create Android notification channel for heads-up display
    const channel = AndroidNotificationChannel(
      'gowork_notifications_channel',
      'GoWork Notifications',
      description: 'Notifications from GoWork application',
      importance: Importance.max,
      playSound: true,
    );
    await _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  Future<void> _requestPermissions() async {
    final settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    debugPrint('=== FCM PERMISSION: ${settings.authorizationStatus} ===');
  }

  Future<void> _registerToken() async {
    try {
      final token = await _firebaseMessaging.getToken();
      if (token != null) {
        await _repository.registerFcmToken(token);
      }
      // Listen for token refresh (e.g. after app reinstall)
      _firebaseMessaging.onTokenRefresh.listen((newToken) {
        _repository.registerFcmToken(newToken);
      });
    } catch (e) {
      debugPrint('=== FCM TOKEN ERROR: $e ===');
    }
  }

  void _listenToForegroundMessages() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final notification = message.notification;
      if (notification == null) return;

      debugPrint('=== FOREGROUND NOTIFICATION: ${notification.title} ===');

      final model = NotificationModel.fromFcm(
        id: message.messageId,
        title: notification.title ?? 'إشعار جديد',
        body: notification.body ?? '',
        imageUrl: notification.android?.imageUrl ?? notification.apple?.imageUrl,
      );

      // Display local notification banner while app is in foreground
      _showLocalNotification(model);

      // Broadcast to ViewModel stream
      _notificationStreamController.add(model);
    });
  }

  void _listenToNotificationTaps() {
    // When user taps a notification while app is in background (but not terminated)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('=== NOTIFICATION TAPPED FROM BACKGROUND: ${message.messageId} ===');
      // Navigation on tap can be handled via the ViewModel or a navigation service
    });
  }

  Future<void> _showLocalNotification(NotificationModel model) async {
    const androidDetails = AndroidNotificationDetails(
      'gowork_notifications_channel',
      'GoWork Notifications',
      channelDescription: 'Notifications from GoWork application',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
      icon: '@mipmap/ic_launcher',
    );
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    const details = NotificationDetails(android: androidDetails, iOS: iosDetails);

    await _localNotifications.show(
      model.id.hashCode,
      model.title,
      model.body,
      details,
      payload: model.id,
    );
  }
}
