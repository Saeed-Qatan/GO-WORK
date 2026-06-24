import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gowork/model/notification_model.dart';
import 'package:gowork/services/push_notification_service.dart';

void main() {
  group('Push notification mapping', () {
    test('maps notification plus data payload', () {
      const message = RemoteMessage(
        messageId: 'remote-1',
        notification: RemoteNotification(
          title: 'Backend title',
          body: 'Backend body',
        ),
        data: {
          'id': '44',
          'notificationId': '144',
          'type': 'JobCreated',
          'actionUrl': '/jobs/90',
        },
      );

      final notification = notificationFromRemoteMessage(message);

      expect(notification, isNotNull);
      expect(notification!.id, 44);
      expect(notification.notificationId, 144);
      expect(notification.title, 'Backend title');
      expect(notification.body, 'Backend body');
      expect(notification.type, NotificationType.jobCreated);
      expect(notification.actionUrl, '/jobs/90');
    });

    test('maps data-only payload with flexible body keys', () {
      const message = RemoteMessage(
        messageId: 'remote-2',
        data: {
          'id': '45',
          'title': 'Data title',
          'message': 'Data body',
          'notificationType': 'InterviewScheduled',
          'action_url': '/interviews/7',
          'image_url': 'https://example.com/image.png',
        },
      );

      final notification = notificationFromRemoteMessage(message);

      expect(notification, isNotNull);
      expect(notification!.id, 45);
      expect(notification.title, 'Data title');
      expect(notification.body, 'Data body');
      expect(notification.type, NotificationType.interviewScheduled);
      expect(notification.actionUrl, '/interviews/7');
      expect(notification.imageUrl, 'https://example.com/image.png');
    });

    test('uses a stable generated id when data id is missing', () {
      final sentTime = DateTime.utc(2026, 6, 10, 8, 30);
      final first = RemoteMessage(
        messageId: 'remote-stable',
        sentTime: sentTime,
        data: const {'title': 'Title', 'body': 'Body'},
      );
      final second = RemoteMessage(
        messageId: 'remote-stable',
        sentTime: sentTime,
        data: const {'body': 'Body', 'title': 'Title'},
      );

      final firstNotification = notificationFromRemoteMessage(first);
      final secondNotification = notificationFromRemoteMessage(second);

      expect(firstNotification, isNotNull);
      expect(secondNotification, isNotNull);
      expect(firstNotification!.id, secondNotification!.id);
      expect(firstNotification.id, greaterThan(0));
    });

    test('skips messages with no displayable notification content', () {
      const message = RemoteMessage(
        messageId: 'remote-empty',
        data: {'id': '1', 'type': 'General'},
      );

      expect(notificationFromRemoteMessage(message), isNull);
    });

    test('encodes local notification tap payload with id and actionUrl', () {
      final notification = NotificationModel.fromFcm(
        id: 60,
        title: 'Tap me',
        body: 'Open details',
        actionUrl: '/jobs/60',
      );

      final decoded = jsonDecode(notificationPayload(notification));

      expect(decoded['id'], 60);
      expect(decoded['actionUrl'], '/jobs/60');
      expect(decoded['notification']['title'], 'Tap me');
    });
  });

  group('Local notification display policy', () {
    test('shows foreground messages from Flutter local notifications', () {
      const message = RemoteMessage(
        notification: RemoteNotification(title: 'Title', body: 'Body'),
      );

      expect(
        shouldDisplayLocalNotificationForLifecycle(
          message,
          NotificationLifecycle.foreground,
        ),
        isTrue,
      );
    });

    test('shows background data-only messages', () {
      const message = RemoteMessage(data: {'title': 'Title', 'body': 'Body'});

      expect(
        shouldDisplayLocalNotificationForLifecycle(
          message,
          NotificationLifecycle.background,
        ),
        isTrue,
      );
    });

    test('does not duplicate background notification block messages', () {
      const message = RemoteMessage(
        notification: RemoteNotification(title: 'Title', body: 'Body'),
      );

      expect(
        shouldDisplayLocalNotificationForLifecycle(
          message,
          NotificationLifecycle.background,
        ),
        isFalse,
      );
    });

    test('does not display a notification again for tap lifecycles', () {
      const message = RemoteMessage(data: {'title': 'Title', 'body': 'Body'});

      expect(
        shouldDisplayLocalNotificationForLifecycle(
          message,
          NotificationLifecycle.openedApp,
        ),
        isFalse,
      );
      expect(
        shouldDisplayLocalNotificationForLifecycle(
          message,
          NotificationLifecycle.initialMessage,
        ),
        isFalse,
      );
    });
  });
}
