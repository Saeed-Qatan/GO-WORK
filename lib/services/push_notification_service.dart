import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../model/notification_model.dart';
import '../repository/notifications_repository.dart';

const String _notificationChannelId = 'gowork_notifications_channel';
const String _notificationChannelName = 'GoWork Notifications';
const String _notificationChannelDescription =
    'Notifications from GoWork application';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint(
    '=== BACKGROUND NOTIFICATION: ${message.notification?.title ?? message.data['title']} ===',
  );

  if (message.notification == null) {
    await _showBackgroundLocalNotification(message);
  }
}

Future<void> _showBackgroundLocalNotification(RemoteMessage message) async {
  final title =
      message.data['title']?.toString() ??
      message.data['notification_title']?.toString();
  final body =
      message.data['body']?.toString() ??
      message.data['message']?.toString() ??
      message.data['notification_body']?.toString();

  if (title == null && body == null) return;

  final localNotifications = FlutterLocalNotificationsPlugin();
  const initSettings = InitializationSettings(
    android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    iOS: DarwinInitializationSettings(),
  );
  await localNotifications.initialize(initSettings);

  const channel = AndroidNotificationChannel(
    _notificationChannelId,
    _notificationChannelName,
    description: _notificationChannelDescription,
    importance: Importance.max,
    playSound: true,
  );
  final androidNotifications = localNotifications
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >();
  await androidNotifications?.createNotificationChannel(channel);

  const details = NotificationDetails(
    android: AndroidNotificationDetails(
      _notificationChannelId,
      _notificationChannelName,
      channelDescription: _notificationChannelDescription,
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
      icon: '@mipmap/ic_launcher',
    ),
    iOS: DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    ),
  );

  await localNotifications.show(
    (message.messageId ?? DateTime.now().millisecondsSinceEpoch.toString())
        .hashCode,
    title ?? 'New notification',
    body ?? '',
    details,
    payload: message.messageId,
  );
}

class PushNotificationService {
  late final FirebaseMessaging _firebaseMessaging;
  final FlutterLocalNotificationsPlugin _localNotifications;
  final NotificationsRepository _repository;
  StreamSubscription<String>? _tokenRefreshSubscription;

  final StreamController<NotificationModel> _notificationStreamController =
      StreamController<NotificationModel>.broadcast();

  Stream<NotificationModel> get onNotificationReceived =>
      _notificationStreamController.stream;

  PushNotificationService({
    FlutterLocalNotificationsPlugin? localNotifications,
    NotificationsRepository? repository,
  }) : _localNotifications =
           localNotifications ?? FlutterLocalNotificationsPlugin(),
       _repository = repository ?? NotificationsRepository();

  Future<void> initialize() async {
    _firebaseMessaging = FirebaseMessaging.instance;
    await _setupLocalNotifications();
    await _requestPermissions();
    await registerCurrentToken();
    _listenToForegroundMessages();
    _listenToNotificationTaps();
  }

  Future<void> registerCurrentToken() async {
    try {
      final token = await _firebaseMessaging.getToken();
      if (token != null) {
        debugPrint('=== FCM TOKEN: $token ===');
        await _repository.registerFcmToken(token);
      }

      _tokenRefreshSubscription ??= _firebaseMessaging.onTokenRefresh.listen((
        newToken,
      ) {
        debugPrint('=== FCM TOKEN REFRESHED: $newToken ===');
        _repository.registerFcmToken(newToken);
      });
    } catch (e) {
      debugPrint('=== FCM TOKEN ERROR: $e ===');
    }
  }

  void dispose() {
    _tokenRefreshSubscription?.cancel();
    _notificationStreamController.close();
  }

  Future<void> _setupLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
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

    const channel = AndroidNotificationChannel(
      _notificationChannelId,
      _notificationChannelName,
      description: _notificationChannelDescription,
      importance: Importance.max,
      playSound: true,
    );

    final androidNotifications = _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    await androidNotifications?.createNotificationChannel(channel);
    await androidNotifications?.requestNotificationsPermission();
  }

  Future<void> _requestPermissions() async {
    final settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    await _firebaseMessaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
    debugPrint('=== FCM PERMISSION: ${settings.authorizationStatus} ===');
  }

  void _listenToForegroundMessages() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final model = _modelFromMessage(message);
      if (model == null) {
        debugPrint('=== FCM: MESSAGE WITHOUT TITLE/BODY: ${message.data} ===');
        return;
      }

      debugPrint('=== FOREGROUND NOTIFICATION: ${model.title} ===');
      _showLocalNotification(model);
      _notificationStreamController.add(model);
    });
  }

  void _listenToNotificationTaps() {
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint(
        '=== NOTIFICATION TAPPED FROM BACKGROUND: ${message.messageId} ===',
      );
    });
  }

  Future<void> _showLocalNotification(NotificationModel model) async {
    const androidDetails = AndroidNotificationDetails(
      _notificationChannelId,
      _notificationChannelName,
      channelDescription: _notificationChannelDescription,
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
    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      model.id.hashCode,
      model.title,
      model.body,
      details,
      payload: model.id,
    );
  }

  NotificationModel? _modelFromMessage(RemoteMessage message) {
    final notification = message.notification;
    final data = message.data;

    final title =
        notification?.title ??
        data['title']?.toString() ??
        data['notification_title']?.toString();
    final body =
        notification?.body ??
        data['body']?.toString() ??
        data['message']?.toString() ??
        data['notification_body']?.toString();

    if (title == null && body == null) return null;

    return NotificationModel.fromFcm(
      id:
          message.messageId ??
          data['id']?.toString() ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      title: title ?? 'New notification',
      body: body ?? '',
      imageUrl:
          notification?.android?.imageUrl ??
          notification?.apple?.imageUrl ??
          data['imageUrl']?.toString() ??
          data['image']?.toString(),
    );
  }
}
