import 'package:flutter_test/flutter_test.dart';
import 'package:gowork/model/notification_model.dart';

void main() {
  group('NotificationModel', () {
    test('parses backend notification payload', () {
      final notification = NotificationModel.fromJson({
        'id': 12,
        'notificationId': 50,
        'title': 'New Job Opportunity!',
        'body': 'Tap to view details and apply!',
        'type': 'JobCreated',
        'deliveryType': 'Topic',
        'createdAt': '2026-06-02T16:30:00Z',
        'isRead': false,
        'actionUrl': '/jobs/100',
        'imageUrl': 'https://example.com/images/job.png',
      });

      expect(notification.id, 12);
      expect(notification.notificationId, 50);
      expect(notification.type, NotificationType.jobCreated);
      expect(notification.deliveryType, NotificationDeliveryType.topic);
      expect(notification.isRead, isFalse);
      expect(notification.actionUrl, '/jobs/100');
      expect(notification.imageUrl, 'https://example.com/images/job.png');
    });

    test('parses all documented notification type enum values', () {
      final cases = {
        'General': NotificationType.general,
        'JobCreated': NotificationType.jobCreated,
        'ApplicationAccepted': NotificationType.applicationAccepted,
        'ApplicationRejected': NotificationType.applicationRejected,
        'InterviewScheduled': NotificationType.interviewScheduled,
      };

      for (final entry in cases.entries) {
        final notification = NotificationModel.fromJson({
          'id': 1,
          'type': entry.key,
        });

        expect(notification.type, entry.value, reason: entry.key);
        expect(notification.typeRaw, entry.key);
      }
    });

    test('keeps unknown enum values from breaking parsing', () {
      final notification = NotificationModel.fromJson({
        'id': 1,
        'type': 'SomethingNew',
        'deliveryType': 'AnotherTarget',
      });

      expect(notification.type, NotificationType.unknown);
      expect(notification.typeRaw, 'SomethingNew');
      expect(notification.deliveryType, NotificationDeliveryType.unknown);
      expect(notification.deliveryTypeRaw, 'AnotherTarget');
    });

    test('parses FCM payload fields', () {
      final notification = NotificationModel.fromFcm(
        id: 77,
        notificationId: 90,
        title: 'Interview',
        body: 'Your interview is scheduled',
        type: 'InterviewScheduled',
        actionUrl: '/interviews/90',
        imageUrl: 'https://example.com/interview.png',
      );

      expect(notification.id, 77);
      expect(notification.notificationId, 90);
      expect(notification.type, NotificationType.interviewScheduled);
      expect(notification.deliveryType, NotificationDeliveryType.unknown);
      expect(notification.isRead, isFalse);
      expect(notification.actionUrl, '/interviews/90');
    });

    test('serializes and restores local cache payload', () {
      final original = NotificationModel.fromJson({
        'id': 12,
        'notificationId': 50,
        'title': 'Title',
        'body': 'Body',
        'type': 'General',
        'deliveryType': 'User',
        'createdAt': '2026-06-02T16:30:00Z',
        'isRead': true,
        'actionUrl': '/jobs/100',
      });

      final restored = NotificationModel.fromJson(original.toJson());

      expect(restored.id, original.id);
      expect(restored.isRead, isTrue);
      expect(restored.createdAt, original.createdAt);
      expect(restored.actionUrl, original.actionUrl);
    });

    test('parses flexible isRead values', () {
      expect(
        NotificationModel.fromJson({'id': 1, 'isRead': true}).isRead,
        isTrue,
      );
      expect(
        NotificationModel.fromJson({'id': 1, 'isRead': 'true'}).isRead,
        isTrue,
      );
      expect(NotificationModel.fromJson({'id': 1, 'isRead': 1}).isRead, isTrue);
      expect(
        NotificationModel.fromJson({'id': 1, 'isRead': false}).isRead,
        isFalse,
      );
      expect(
        NotificationModel.fromJson({'id': 1, 'isRead': 'false'}).isRead,
        isFalse,
      );
      expect(
        NotificationModel.fromJson({'id': 1, 'isRead': 0}).isRead,
        isFalse,
      );
    });
  });
}
