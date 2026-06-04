import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:gowork/model/notification_model.dart';
import 'package:gowork/repository/notifications_repository.dart';
import 'package:gowork/services/push_notification_service.dart';
import 'package:gowork/viewmodel/notifications_view_model.dart';

class _FakeNotificationsRepository extends NotificationsRepository {
  final Map<int, NotificationsPage> pages;
  int unreadCount;
  bool failMarkRead = false;
  bool failHide = false;
  int markReadCount = 0;
  int markAllCount = 0;
  int hideCount = 0;

  _FakeNotificationsRepository({required this.pages, this.unreadCount = 0});

  @override
  Future<NotificationsPage> getNotifications({
    int pageNumber = 1,
    int pageSize = 20,
  }) async {
    return pages[pageNumber] ??
        const NotificationsPage(
          items: [],
          currentPage: 1,
          pageSize: 20,
          totalCount: 0,
          totalPages: 1,
        );
  }

  @override
  Future<int> getUnreadCount() async => unreadCount;

  @override
  Future<void> markAsRead(int notificationId) async {
    markReadCount++;
    if (failMarkRead) throw Exception('mark failed');
  }

  @override
  Future<void> markAllAsRead() async {
    markAllCount++;
  }

  @override
  Future<void> hideNotification(int notificationId) async {
    hideCount++;
    if (failHide) throw Exception('hide failed');
  }
}

class _FakePushNotificationService extends PushNotificationService {
  final StreamController<NotificationModel> controller =
      StreamController<NotificationModel>.broadcast();

  @override
  Stream<NotificationModel> get onNotificationReceived => controller.stream;

  void add(NotificationModel notification) {
    controller.add(notification);
  }
}

void main() {
  group('NotificationsViewModel', () {
    test('loads first page and unread count', () async {
      final repository = _FakeNotificationsRepository(
        unreadCount: 2,
        pages: {
          1: NotificationsPage(
            items: [_notification(id: 1), _notification(id: 2)],
            currentPage: 1,
            pageSize: 20,
            totalCount: 2,
            totalPages: 1,
          ),
        },
      );
      final viewModel = NotificationsViewModel(
        repository: repository,
        pushService: _FakePushNotificationService(),
        autoFetchUnreadCount: false,
      );

      await viewModel.fetchNotifications();

      expect(viewModel.viewState, NotificationsViewState.loaded);
      expect(viewModel.notifications.map((item) => item.id), [1, 2]);
      expect(viewModel.unreadCount, 2);
    });

    test('loads more pages when available', () async {
      final repository = _FakeNotificationsRepository(
        pages: {
          1: NotificationsPage(
            items: [_notification(id: 1)],
            currentPage: 1,
            pageSize: 20,
            totalCount: 2,
            totalPages: 2,
          ),
          2: NotificationsPage(
            items: [_notification(id: 2)],
            currentPage: 2,
            pageSize: 20,
            totalCount: 2,
            totalPages: 2,
          ),
        },
      );
      final viewModel = NotificationsViewModel(
        repository: repository,
        pushService: _FakePushNotificationService(),
        autoFetchUnreadCount: false,
      );

      await viewModel.fetchNotifications();
      await viewModel.loadMore();

      expect(viewModel.notifications.map((item) => item.id), [1, 2]);
      expect(viewModel.hasMore, isFalse);
    });

    test('rolls back optimistic mark as read on failure', () async {
      final repository = _FakeNotificationsRepository(
        unreadCount: 1,
        pages: {
          1: NotificationsPage(
            items: [_notification(id: 1, isRead: false)],
            currentPage: 1,
            pageSize: 20,
            totalCount: 1,
            totalPages: 1,
          ),
        },
      )..failMarkRead = true;
      final viewModel = NotificationsViewModel(
        repository: repository,
        pushService: _FakePushNotificationService(),
        autoFetchUnreadCount: false,
      );

      await viewModel.fetchNotifications();
      await viewModel.markAsRead(1);

      expect(viewModel.notifications.single.isRead, isFalse);
      expect(viewModel.unreadCount, 1);
      expect(repository.markReadCount, 1);
    });

    test('marks all as read optimistically', () async {
      final repository = _FakeNotificationsRepository(
        unreadCount: 2,
        pages: {
          1: NotificationsPage(
            items: [
              _notification(id: 1, isRead: false),
              _notification(id: 2, isRead: false),
            ],
            currentPage: 1,
            pageSize: 20,
            totalCount: 2,
            totalPages: 1,
          ),
        },
      );
      final viewModel = NotificationsViewModel(
        repository: repository,
        pushService: _FakePushNotificationService(),
        autoFetchUnreadCount: false,
      );

      await viewModel.fetchNotifications();
      await viewModel.markAllAsRead();

      expect(viewModel.notifications.every((item) => item.isRead), isTrue);
      expect(viewModel.unreadCount, 0);
      expect(repository.markAllCount, 1);
    });

    test('hides notification optimistically', () async {
      final repository = _FakeNotificationsRepository(
        unreadCount: 1,
        pages: {
          1: NotificationsPage(
            items: [_notification(id: 1, isRead: false)],
            currentPage: 1,
            pageSize: 20,
            totalCount: 1,
            totalPages: 1,
          ),
        },
      );
      final viewModel = NotificationsViewModel(
        repository: repository,
        pushService: _FakePushNotificationService(),
        autoFetchUnreadCount: false,
      );

      await viewModel.fetchNotifications();
      await viewModel.hideNotification(1);

      expect(viewModel.notifications, isEmpty);
      expect(viewModel.viewState, NotificationsViewState.empty);
      expect(viewModel.unreadCount, 0);
      expect(repository.hideCount, 1);
    });

    test('prepends live push notifications and refreshes count', () async {
      final pushService = _FakePushNotificationService();
      final repository = _FakeNotificationsRepository(
        unreadCount: 4,
        pages: {
          1: const NotificationsPage(
            items: [],
            currentPage: 1,
            pageSize: 20,
            totalCount: 0,
            totalPages: 1,
          ),
        },
      );
      final viewModel = NotificationsViewModel(
        repository: repository,
        pushService: pushService,
        autoFetchUnreadCount: false,
      );

      await viewModel.fetchNotifications();
      pushService.add(_notification(id: 9, isRead: false));
      await Future<void>.delayed(Duration.zero);

      expect(viewModel.notifications.single.id, 9);
      expect(viewModel.viewState, NotificationsViewState.loaded);
      expect(viewModel.unreadCount, 4);
    });
  });
}

NotificationModel _notification({required int id, bool isRead = false}) {
  return NotificationModel(
    id: id,
    notificationId: id + 100,
    title: 'Title $id',
    body: 'Body $id',
    type: NotificationType.general,
    typeRaw: 'General',
    deliveryType: NotificationDeliveryType.user,
    deliveryTypeRaw: 'User',
    createdAt: DateTime.utc(2026, 6, 2, 16, 30),
    isRead: isRead,
    actionUrl: '/jobs/$id',
  );
}
