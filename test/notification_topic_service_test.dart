import 'package:flutter_test/flutter_test.dart';
import 'package:gowork/services/notification_topic_service.dart';

class FakeTopicMessaging implements TopicMessaging {
  final List<String> subscribedTopics = [];
  final List<String> unsubscribedTopics = [];

  @override
  Future<void> subscribeToTopic(String topic) async {
    subscribedTopics.add(topic);
  }

  @override
  Future<void> unsubscribeFromTopic(String topic) async {
    unsubscribedTopics.add(topic);
  }
}

void main() {
  group('NotificationTopicService', () {
    test('subscribeUserTopics ignores empty category topics', () async {
      final messaging = FakeTopicMessaging();
      final service = NotificationTopicService(topicMessaging: messaging);

      await service.subscribeUserTopics(categoryId: '  ');

      expect(messaging.subscribedTopics, ['all']);
      expect(messaging.unsubscribedTopics, isEmpty);
    });

    test('syncUserTopics does not resubscribe unchanged category', () async {
      final messaging = FakeTopicMessaging();
      final service = NotificationTopicService(topicMessaging: messaging);

      await service.syncUserTopics(
        previousCategoryId: '101',
        categoryId: '101',
      );

      expect(messaging.subscribedTopics, ['all']);
      expect(messaging.unsubscribedTopics, isEmpty);
    });

    test(
      'syncUserTopics subscribes new category and unsubscribes old',
      () async {
        final messaging = FakeTopicMessaging();
        final service = NotificationTopicService(topicMessaging: messaging);

        await service.syncUserTopics(
          previousCategoryId: '101',
          categoryId: '205',
        );

        expect(messaging.subscribedTopics, ['all', 'category_205']);
        expect(messaging.unsubscribedTopics, ['category_101']);
      },
    );
  });
}
