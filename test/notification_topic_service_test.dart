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

class FakeCategoryResolver extends NotificationCategoryResolver {
  final Map<String, NotificationCategory> categories;

  FakeCategoryResolver(this.categories);

  @override
  Future<NotificationCategory?> resolveById(String categoryId) async {
    return categories[categoryId.trim()];
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
        final service = NotificationTopicService(
          topicMessaging: messaging,
          categoryResolver: FakeCategoryResolver({
            '205': const NotificationCategory(
              id: '205',
              name: 'Backend Development',
            ),
            '101': const NotificationCategory(
              id: '101',
              name: 'Mobile Development',
            ),
          }),
        );

        await service.syncUserTopics(
          previousCategoryId: '101',
          categoryId: '205',
        );

        expect(messaging.subscribedTopics, [
          'all',
          'category_205',
          'Backend%20Development_205',
          'Backend_Development_205',
        ]);
        expect(messaging.unsubscribedTopics, [
          'category_101',
          'Mobile%20Development_101',
          'Mobile_Development_101',
        ]);
      },
    );

    test('subscribeUserTopics includes backend topic when category name exists', () async {
      final messaging = FakeTopicMessaging();
      final service = NotificationTopicService(
        topicMessaging: messaging,
        categoryResolver: FakeCategoryResolver({
          '3': const NotificationCategory(
            id: '3',
            name: 'Backend Development',
          ),
        }),
      );

      await service.subscribeUserTopics(categoryId: '3');

      expect(messaging.subscribedTopics, [
        'all',
        'category_3',
        'Backend%20Development_3',
        'Backend_Development_3',
      ]);
      expect(messaging.unsubscribedTopics, isEmpty);
    });
  });
}
