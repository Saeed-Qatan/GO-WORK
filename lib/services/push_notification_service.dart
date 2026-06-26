import 'dart:async';
import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../model/notification_model.dart';
import '../repository/notifications_repository.dart';
import 'notification_identity.dart';
import 'notifications_local_store.dart';

const String _notificationChannelId = 'gowork_notifications_high_channel';
const String _notificationChannelName = 'GoWork Notifications';
const String _notificationChannelDescription =
    'Notifications from GoWork application';
const String _notificationIcon = 'ic_notification';

enum NotificationLifecycle { foreground, background, openedApp, initialMessage }

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

  final service = PushNotificationService(
    localNotifications: FlutterLocalNotificationsPlugin(),
  );
  await service.showLocalNotification(
    message,
    lifecycle: NotificationLifecycle.background,
  );
}

/// Logs all relevant fields of an FCM message including topic origin.
/// [message.from] contains the topic path (e.g. /topics/category_42)
/// when the message was sent to a topic instead of a direct token.
void _debugLogMessage({required String label, required RemoteMessage message}) {
  final from = message.from ?? 'UNKNOWN';
  final isTopic = from.startsWith('/topics/');
  final topicName = isTopic ? from.replaceFirst('/topics/', '') : null;
  final isCategory = topicName?.startsWith('category_') ?? false;

  debugPrint('=== FCM [$label] MESSAGE RECEIVED ===');
  debugPrint('from       : $from');
  debugPrint('is topic   : $isTopic');
  debugPrint('topic name : ${topicName ?? "-"}');
  debugPrint('is category: $isCategory');
  if (isCategory) {
    final categoryId = topicName!.replaceFirst('category_', '');
    debugPrint('category id: $categoryId');
  }
  debugPrint('messageId  : ${message.messageId ?? "-"}');
  debugPrint('sentTime   : ${message.sentTime ?? "-"}');
  debugPrint('notif.title: ${message.notification?.title ?? "-"}');
  debugPrint('notif.body : ${message.notification?.body ?? "-"}');
  debugPrint('data       : ${message.data}');
}

class PushNotificationService {
  late final FirebaseMessaging _firebaseMessaging;
  final FlutterLocalNotificationsPlugin _localNotifications;
  final NotificationsRepository _repository;
  final NotificationsLocalStore _localStore;
  StreamSubscription<String>? _tokenRefreshSubscription;
  StreamSubscription<RemoteMessage>? _foregroundMessageSubscription;
  StreamSubscription<RemoteMessage>? _messageOpenedSubscription;
  bool _localNotificationsReady = false;
  bool _handlersRegistered = false;

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
    await _requestPermissions();
    await _setupLocalNotifications(createChannels: true);
    await _registerHandlers();
    unawaited(registerCurrentToken());
  }

  Future<void> ensureDeviceNotificationSetup() async {
    try {
      await _requestPermissions();
      await _setupLocalNotifications(createChannels: true);
    } catch (e) {
      debugPrint('=== FCM: ENSURE NOTIFICATION SETUP ERROR: $e ===');
    }
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
        unawaited(_repository.registerFcmToken(newToken));
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
    _foregroundMessageSubscription?.cancel();
    _messageOpenedSubscription?.cancel();
    _notificationStreamController.close();
    _notificationTapStreamController.close();
  }

  NotificationTapAction? takePendingTappedNotificationAction() {
    final action = _pendingTappedNotificationAction;
    _pendingTappedNotificationAction = null;
    _hasPendingNotificationTap = false;
    return action;
  }

  Future<NotificationModel?> showLocalNotification(
    RemoteMessage message, {
    required NotificationLifecycle lifecycle,
  }) async {
    final model = notificationFromRemoteMessage(message);
    if (model == null) {
      debugPrint('=== FCM: MESSAGE WITHOUT TITLE/BODY - skipping ===');
      return null;
    }
    debugPrint(
      '=== FCM: MAPPED NOTIFICATION ${notificationDebugIdentity(model)} '
      'messageId=${message.messageId ?? "-"} from=${message.from ?? "-"} ===',
    );

    await _safeUpsert(model);

    if (_shouldDisplayLocalNotification(message, lifecycle)) {
      // [FIX-2] في الـ background isolate يعمل الكود في Dart VM منفصلة.
      // الـ channel لم يُنشأ بعد في تلك البيئة — يجب إنشاؤه دائماً.
      final isBackgroundIsolate = lifecycle == NotificationLifecycle.background;
      await _setupLocalNotifications(createChannels: isBackgroundIsolate);
      await _showLocalNotification(model);
    } else {
      debugPrint(
        '=== LOCAL NOTIFICATION SKIPPED: lifecycle=$lifecycle id=${model.id} ===',
      );
    }

    if (lifecycle == NotificationLifecycle.foreground) {
      _notificationStreamController.add(model);
    }

    return model;
  }

  Future<void> _setupLocalNotifications({required bool createChannels}) async {
    if (!_localNotificationsReady) {
      await _localNotifications.initialize(
        _localNotificationInitializationSettings,
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

      _localNotificationsReady = true;
    }

    if (createChannels) {
      await _createAndroidNotificationChannel();
      final androidPermissionGranted = await _androidNotifications()
          ?.requestNotificationsPermission();
      debugPrint(
        '=== LOCAL NOTIFICATIONS ANDROID PERMISSION: $androidPermissionGranted ===',
      );
    }
  }

  Future<void> _createAndroidNotificationChannel() async {
    const channel = AndroidNotificationChannel(
      _notificationChannelId,
      _notificationChannelName,
      description: _notificationChannelDescription,
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
      showBadge: true,
    );

    await _androidNotifications()?.createNotificationChannel(channel);
  }

  AndroidFlutterLocalNotificationsPlugin? _androidNotifications() {
    return _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
  }

  Future<void> _requestPermissions() async {
    final settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    // [FIX-1] alert:false = نتحكم يدوياً عبر flutter_local_notifications لتجنب التكرار.
    // badge+sound يجب أن يبقيا true حتى يعمل الصوت والـ badge على iOS.
    await _firebaseMessaging.setForegroundNotificationPresentationOptions(
      alert: false,
      badge: true,
      sound: true,
    );
    debugPrint('=== FCM PERMISSION: ${settings.authorizationStatus} ===');
  }

  Future<void> _registerHandlers() async {
    if (_handlersRegistered) return;
    _handlersRegistered = true;

    _foregroundMessageSubscription = FirebaseMessaging.onMessage.listen((
      message,
    ) {
      _debugLogMessage(label: 'FOREGROUND', message: message);
      unawaited(
        showLocalNotification(
          message,
          lifecycle: NotificationLifecycle.foreground,
        ),
      );
    });

    _messageOpenedSubscription = FirebaseMessaging.onMessageOpenedApp.listen((
      message,
    ) {
      unawaited(_handleRemoteMessageTap(message, NotificationLifecycle.openedApp));
    });

    final initialMessage = await _firebaseMessaging.getInitialMessage();
    if (initialMessage != null) {
      await _handleRemoteMessageTap(
        initialMessage,
        NotificationLifecycle.initialMessage,
      );
    }
  }

  Future<void> _handleRemoteMessageTap(
    RemoteMessage message,
    NotificationLifecycle lifecycle,
  ) async {
    _debugLogMessage(label: lifecycle.name, message: message);
    final model = await showLocalNotification(message, lifecycle: lifecycle);
    _handleNotificationTap(_tapActionFromNotification(model));
  }

  void _handleNotificationTap(NotificationTapAction? action) {
    final tapAction = action ?? const NotificationTapAction();
    _pendingTappedNotificationAction = tapAction;
    _hasPendingNotificationTap = true;
    _notificationTapStreamController.add(tapAction);
  }

  Future<void> _showLocalNotification(NotificationModel model) async {
    try {
      await _localNotifications.show(
        model.id,
        model.displayTitle,
        model.displayBody,
        _localNotificationDetails,
        payload: notificationPayload(model),
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
      // Older local notifications used the id as a plain payload.
    }

    return NotificationTapAction(
      notificationId: _parseRemoteOptionalInt(payload),
    );
  }
}

const InitializationSettings _localNotificationInitializationSettings =
    InitializationSettings(
      android: AndroidInitializationSettings(_notificationIcon),
      iOS: DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      ),
    );

const NotificationDetails _localNotificationDetails = NotificationDetails(
  android: AndroidNotificationDetails(
    _notificationChannelId,
    _notificationChannelName,
    channelDescription: _notificationChannelDescription,
    importance: Importance.max,
    priority: Priority.max,
    showWhen: true,
    icon: _notificationIcon,
    playSound: true,
    enableVibration: true,
    channelShowBadge: true,
  ),
  iOS: DarwinNotificationDetails(
    presentAlert: true,
    presentBadge: true,
    presentSound: true,
  ),
);

NotificationTapAction? _tapActionFromNotification(NotificationModel? model) {
  if (model == null) return null;
  return NotificationTapAction(
    notificationId: model.id,
    actionUrl: model.actionUrl,
    notification: model,
  );
}

String notificationPayload(NotificationModel model) {
  return jsonEncode({
    'id': model.id,
    'actionUrl': model.actionUrl,
    'notification': model.toJson(),
  });
}

@visibleForTesting
bool shouldDisplayLocalNotificationForLifecycle(
  RemoteMessage message,
  NotificationLifecycle lifecycle,
) {
  return _shouldDisplayLocalNotification(message, lifecycle);
}

bool _shouldDisplayLocalNotification(
  RemoteMessage message,
  NotificationLifecycle lifecycle,
) {
  switch (lifecycle) {
    case NotificationLifecycle.foreground:
      // دائماً نعرض في الـ foreground عبر flutter_local_notifications.
      return true;
    case NotificationLifecycle.background:
      // [FIX-3] إذا جاءت رسالة مع notification object، FCM يعرضها تلقائياً
      // في شريط الإشعارات. نعرض يدوياً فقط رسائل data-only.
      // إذا أرسل الباكند data-only (بدون notification)، هذا يُعيد true.
      return message.notification == null;
    case NotificationLifecycle.openedApp:
    case NotificationLifecycle.initialMessage:
      // المستخدم بدأ التفاعل بالفعل — لا داعي لإشعار مرئي إضافي.
      return false;
  }
}

@visibleForTesting
NotificationModel? notificationFromRemoteMessage(RemoteMessage message) {
  final notification = message.notification;
  final data = message.data;

  final title = _firstNonEmpty([
    notification?.title,
    data['title'],
    data['Title'],
    data['notification_title'],
    data['notificationTitle'],
    data['NotificationTitle'],
  ]);
  final body = _firstNonEmpty([
    notification?.body,
    data['body'],
    data['Body'],
    data['message'],
    data['Message'],
    data['notification_body'],
    data['notificationBody'],
    data['NotificationBody'],
  ]);

  if (title == null && body == null) return null;

  return NotificationModel.fromFcm(
    id: _parseRemoteOptionalInt(data['id']) ?? _stableMessageId(message),
    notificationId: _parseRemoteOptionalInt(data['notificationId']),
    title: title ?? 'New notification',
    body: body ?? '',
    type: _firstNonEmpty([data['type'], data['notificationType']]),
    actionUrl: _firstNonEmpty([
      data['actionUrl'],
      data['action_url'],
      data['url'],
    ]),
    imageUrl:
        notification?.android?.imageUrl ??
        notification?.apple?.imageUrl ??
        _firstNonEmpty([data['imageUrl'], data['image'], data['image_url']]),
  );
}

String? _firstNonEmpty(Iterable<dynamic> values) {
  for (final value in values) {
    final text = value?.toString().trim();
    if (text != null && text.isNotEmpty) return text;
  }
  return null;
}

int? _parseRemoteOptionalInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  return int.tryParse(value.toString());
}

int _stableMessageId(RemoteMessage message) {
  final source = [
    message.messageId,
    message.sentTime?.toIso8601String(),
    message.from,
    message.notification?.title,
    message.notification?.body,
    _stableDataString(message.data),
  ].whereType<String>().join('|');
  return _stablePositiveId(source.isEmpty ? DateTime.now().toIso8601String() : source);
}

String _stableDataString(Map<String, dynamic> data) {
  final sorted = Map<String, dynamic>.fromEntries(
    data.entries.toList()..sort((a, b) => a.key.compareTo(b.key)),
  );
  return jsonEncode(sorted);
}

int _stablePositiveId(String source) {
  var hash = 0x811c9dc5;
  for (var i = 0; i < source.length; i++) {
    hash ^= source.codeUnitAt(i);
    hash = (hash * 0x01000193) & 0x7fffffff;
  }
  return hash == 0 ? 1 : hash;
}
