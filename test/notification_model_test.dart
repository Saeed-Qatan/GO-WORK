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
  });
}
