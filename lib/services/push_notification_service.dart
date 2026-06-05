import 'dart:async';
import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../model/notification_model.dart';
import '../repository/notifications_repository.dart';
import 'notifications_local_store.dart';

const String _notificationChannelId = 'gowork_notifications_channel';
const String _notificationChannelName = 'GoWork Notifications';
const String _notificationChannelDescription =
    'Notifications from GoWork application';
const String _notificationIcon = '@mipmap/ic_launcher';

class NotificationTapAction {
  final int? notificationId;
  final String? actionUrl;
  final NotificationModel? notification;

  const NotificationTapAction({
    this.notificationId,
    this.actionUrl,
    this.notification,
  });

  bool get hasTarget =>
      notificationId != null || (actionUrl != null && actionUrl!.isNotEmpty);
}

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  _debugLogMessage(label: 'BACKGROUND', message: message);

  if (message.notification == null) {
    await _showBackgroundLocalNotification(message);
  }

  final model = _notificationFromMessage(message);
  if (model != null) {
    try {
      await NotificationsLocalStore().upsert(model);
    } catch (e) {
      debugPrint('=== BACKGROUND NOTIFICATION CACHE ERROR: $e ===');
    }
  }
}

Future<void> _showBackgroundLocalNotification(RemoteMessage message) async {
  final model = _notificationFromMessage(message);
  if (model == null) return;

  final localNotifications = FlutterLocalNotificationsPlugin();
  const initSettings = InitializationSettings(
    android: AndroidInitializationSettings(_notificationIcon),
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
      icon: _notificationIcon,
    ),
    iOS: DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    ),
  );

  try {
    await localNotifications.show(
      (message.messageId ?? DateTime.now().millisecondsSinceEpoch.toString())
          .hashCode,
      model.title,
      model.body,
      details,
      payload: _notificationPayload(model),
    );
  } catch (e) {
    debugPrint('=== LOCAL BACKGROUND NOTIFICATION SHOW ERROR: $e ===');
  }
}

/// Logs all relevant fields of an FCM message including topic origin.
/// [message.from] contains the topic path (e.g. /topics/category_42)
/// when the message was sent to a topic instead of a direct token.
void _debugLogMessage({required String label, required RemoteMessage message}) {
  final from = message.from ?? 'UNKNOWN';
  final isTopic = from.startsWith('/topics/');
  final topicName = isTopic ? from.replaceFirst('/topics/', '') : null;
  final isCategory = topicName?.startsWith('category_') ?? false;

  debugPrint('\n╔════════════════════════════════════════════╗');
  debugPrint('║  FCM [$label] MESSAGE RECEIVED');
  debugPrint('╠════════════════════════════════════════════╣');
  debugPrint('║  from       : $from');
  debugPrint('║  is topic   : $isTopic');
  debugPrint('║  topic name : ${topicName ?? "—"}');
  debugPrint('║  is category: $isCategory');
  if (isCategory) {
    final categoryId = topicName!.replaceFirst('category_', '');
    debugPrint('║  category id: $categoryId  ✅ MATCHED');
  } else {
    debugPrint('║  category id: —  ❌ NOT a category topic');
  }
  debugPrint('╠════════════════════════════════════════════╣');
  debugPrint('║  messageId  : ${message.messageId ?? "—"}');
  debugPrint('║  sentTime   : ${message.sentTime ?? "—"}');
  debugPrint('║  notif.title: ${message.notification?.title ?? "—"}');
  debugPrint('║  notif.body : ${message.notification?.body ?? "—"}');
  debugPrint('╠════════════════════════════════════════════╣');
  debugPrint('║  data payload:');
  if (message.data.isEmpty) {
    debugPrint('║    (empty)');
  } else {
    message.data.forEach((key, value) {
      debugPrint('║    $key: $value');
    });
  }
  debugPrint('╚════════════════════════════════════════════╝\n');
}

class PushNotificationService {
  late final FirebaseMessaging _firebaseMessaging;
  final FlutterLocalNotificationsPlugin _localNotifications;
  final NotificationsRepository _repository;
  final NotificationsLocalStore _localStore;
  StreamSubscription<String>? _tokenRefreshSubscription;

  final StreamController<NotificationModel> _notificationStreamController =
      StreamController<NotificationModel>.broadcast();
  final StreamController<NotificationTapAction>
  _notificationTapStreamController =
      StreamController<NotificationTapAction>.broadcast();
  NotificationTapAction? _pendingTappedNotificationAction;
  bool _hasPendingNotificationTap = false;

  Stream<NotificationModel> get onNotificationReceived =>
      _notificationStreamController.stream;
  Stream<NotificationTapAction> get onNotificationTapped =>
      _notificationTapStreamController.stream;
  bool get hasPendingNotificationTap => _hasPendingNotificationTap;

  PushNotificationService({
    FlutterLocalNotificationsPlugin? localNotifications,
    NotificationsRepository? repository,
    NotificationsLocalStore? localStore,
  }) : _localNotifications =
           localNotifications ?? FlutterLocalNotificationsPlugin(),
       _repository = repository ?? NotificationsRepository(),
       _localStore = localStore ?? NotificationsLocalStore();

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
        debugPrint('=== FCM TOKEN: ${_maskToken(token)} ===');
        await _repository.registerFcmToken(token);
      }

      _tokenRefreshSubscription ??= _firebaseMessaging.onTokenRefresh.listen((
        newToken,
      ) {
        debugPrint('=== FCM TOKEN REFRESHED: ${_maskToken(newToken)} ===');
        _repository.registerFcmToken(newToken);
      });
    } catch (e) {
      debugPrint('=== FCM TOKEN ERROR: $e ===');
    }
  }

  String _maskToken(String token) {
    if (token.length <= 12) return '***';
    return '${token.substring(0, 6)}...${token.substring(token.length - 6)}';
  }

  void dispose() {
    _tokenRefreshSubscription?.cancel();
    _notificationStreamController.close();
    _notificationTapStreamController.close();
  }

  NotificationTapAction? takePendingTappedNotificationAction() {
    final action = _pendingTappedNotificationAction;
    _pendingTappedNotificationAction = null;
    _hasPendingNotificationTap = false;
    return action;
  }

  Future<void> _setupLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings(_notificationIcon);
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
        _handleNotificationTap(_tapActionFromPayload(response.payload));
      },
    );

    final launchDetails = await _localNotifications
        .getNotificationAppLaunchDetails();
    if (launchDetails?.didNotificationLaunchApp == true) {
      _handleNotificationTap(
        _tapActionFromPayload(launchDetails?.notificationResponse?.payload),
      );
    }

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
    final androidPermissionGranted = await androidNotifications
        ?.requestNotificationsPermission();
    debugPrint(
      '=== LOCAL NOTIFICATIONS ANDROID PERMISSION: $androidPermissionGranted ===',
    );
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
      _debugLogMessage(label: 'FOREGROUND', message: message);

      final model = _notificationFromMessage(message);
      if (model == null) {
        debugPrint(
          '=== FCM: MESSAGE WITHOUT TITLE/BODY — skipping local notification ===',
        );
        return;
      }

      unawaited(_showLocalNotification(model));
      unawaited(_safeUpsert(model));
      _notificationStreamController.add(model);
    });
  }

  void _listenToNotificationTaps() {
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _debugLogMessage(
        label: 'TAPPED (opened from background)',
        message: message,
      );
      final model = _notificationFromMessage(message);
      if (model != null) {
        unawaited(_localStore.upsert(model));
      }
      _handleNotificationTap(_tapActionFromNotification(model));
    });

    unawaited(
      _firebaseMessaging.getInitialMessage().then((message) {
        if (message == null) return;
        _debugLogMessage(
          label: 'TAPPED (opened from terminated)',
          message: message,
        );
        final model = _notificationFromMessage(message);
        if (model != null) {
          unawaited(_localStore.upsert(model));
        }
        _handleNotificationTap(_tapActionFromNotification(model));
      }),
    );
  }

  void _handleNotificationTap(NotificationTapAction? action) {
    final tapAction = action ?? const NotificationTapAction();
    _pendingTappedNotificationAction = tapAction;
    _hasPendingNotificationTap = true;
    _notificationTapStreamController.add(tapAction);
  }

  Future<void> _showLocalNotification(NotificationModel model) async {
    const androidDetails = AndroidNotificationDetails(
      _notificationChannelId,
      _notificationChannelName,
      channelDescription: _notificationChannelDescription,
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
      icon: _notificationIcon,
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

    try {
      await _localNotifications.show(
        model.id.hashCode,
        model.title,
        model.body,
        details,
        payload: _notificationPayload(model),
      );
      debugPrint('=== LOCAL NOTIFICATION SHOWN: ${model.id} ===');
    } catch (e) {
      debugPrint('=== LOCAL NOTIFICATION SHOW ERROR: $e ===');
    }
  }

  Future<void> _safeUpsert(NotificationModel model) async {
    try {
      await _localStore.upsert(model);
    } catch (e) {
      debugPrint('=== NOTIFICATION CACHE UPSERT ERROR: $e ===');
    }
  }

  NotificationTapAction _tapActionFromPayload(String? payload) {
    if (payload == null || payload.trim().isEmpty) {
      return const NotificationTapAction();
    }

    try {
      final decoded = jsonDecode(payload);
      if (decoded is Map<String, dynamic>) {
        final notification = decoded['notification'] is Map<String, dynamic>
            ? NotificationModel.fromJson(
                decoded['notification'] as Map<String, dynamic>,
              )
            : null;
        return NotificationTapAction(
          notificationId:
              _parseRemoteOptionalInt(decoded['id']) ?? notification?.id,
          actionUrl:
              decoded['actionUrl']?.toString() ?? notification?.actionUrl,
          notification: notification,
        );
      }
    } catch (_) {
      // Older cached local notifications used the id as a plain payload.
    }

    return NotificationTapAction(
      notificationId: _parseRemoteOptionalInt(payload),
    );
  }
}

NotificationTapAction? _tapActionFromNotification(NotificationModel? model) {
  if (model == null) return null;
  return NotificationTapAction(
    notificationId: model.id,
    actionUrl: model.actionUrl,
    notification: model,
  );
}

String _notificationPayload(NotificationModel model) {
  return jsonEncode({
    'id': model.id,
    'actionUrl': model.actionUrl,
    'notification': model.toJson(),
  });
}

NotificationModel? _notificationFromMessage(RemoteMessage message) {
  final notification = message.notification;
  final data = message.data;

  final title =
      notification?.title ??
      data['title']?.toString() ??
      data['notification_title']?.toString() ??
      data['notificationTitle']?.toString() ??
      data['NotificationTitle']?.toString();
  final body =
      notification?.body ??
      data['body']?.toString() ??
      data['message']?.toString() ??
      data['notification_body']?.toString() ??
      data['notificationBody']?.toString() ??
      data['NotificationBody']?.toString();

  if (title == null && body == null) return null;

  return NotificationModel.fromFcm(
    id: _parseRemoteOptionalInt(data['id']) ?? message.messageId?.hashCode,
    notificationId: _parseRemoteOptionalInt(data['notificationId']),
    title: title ?? 'New notification',
    body: body ?? '',
    type: data['type']?.toString(),
    actionUrl:
        data['actionUrl']?.toString() ??
        data['action_url']?.toString() ??
        data['url']?.toString(),
    imageUrl:
        notification?.android?.imageUrl ??
        notification?.apple?.imageUrl ??
        data['imageUrl']?.toString() ??
        data['image']?.toString(),
  );
}

int? _parseRemoteOptionalInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  return int.tryParse(value.toString());
}
