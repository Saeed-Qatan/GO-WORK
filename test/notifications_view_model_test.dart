import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:gowork/model/notification_model.dart';
import 'package:gowork/repository/notifications_repository.dart';
import 'package:gowork/services/notifications_local_store.dart';
import 'package:gowork/services/push_notification_service.dart';
import 'package:gowork/utils/local_storage.dart';
import 'package:gowork/viewmodel/notifications_view_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeNotificationsRepository extends NotificationsRepository {
  final Map<int, NotificationsPage> pages;
  int unreadCount;
  bool failMarkRead = false;
  bool failMarkAll = false;
  bool failHide = false;
  bool failGetNotifications = false;
  bool failUnreadCount = false;
  int markReadCount = 0;
  int markAllCount = 0;
  int hideCount = 0;
  final List<int> markReadIds = [];

  _FakeNotificationsRepository({required this.pages, this.unreadCount = 0});

  @override
  Future<NotificationsPage> getNotifications({
    int pageNumber = 1,
    int pageSize = 20,
  }) async {
    if (failGetNotifications) throw Exception('fetch failed');
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
  Future<int> getUnreadCount() async {
    if (failUnreadCount) throw Exception('unread count failed');
    return unreadCount;
  }

  @override
  Future<void> markAsRead(int notificationId) async {
    markReadCount++;
    markReadIds.add(notificationId);
    if (failMarkRead) throw Exception('mark failed');
    unreadCount = (unreadCount - 1).clamp(0, 1 << 31).toInt();
  }

  @override
  Future<void> markAllAsRead() async {
    markAllCount++;
    if (failMarkAll) throw Exception('mark all failed');
    unreadCount = 0;
  }

  @override
  Future<void> hideNotification(int notificationId) async {
    hideCount++;
    if (failHide) throw Exception('hide failed');
    unreadCount = (unreadCount - 1).clamp(0, 1 << 31).toInt();
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

class _FakeNotificationsLocalStore extends NotificationsLocalStore {
  List<NotificationModel> stored;
  int saveCount = 0;

  _FakeNotificationsLocalStore([this.stored = const []]);

  @override
  Future<List<NotificationModel>> load() async => stored;

  @override
  Future<void> save(List<NotificationModel> notifications) async {
    saveCount++;
    stored = List<NotificationModel>.from(notifications);
  }

  @override
  Future<void> upsert(NotificationModel notification) async {
    await save([notification, ...stored]);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('NotificationsViewModel', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

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
        localStore: _FakeNotificationsLocalStore(),
        autoFetchUnreadCount: false,
      );

      await viewModel.fetchNotifications();

      expect(viewModel.viewState, NotificationsViewState.loaded);
      expect(viewModel.notifications.map((item) => item.id), [1, 2]);
      expect(viewModel.unreadCount, 2);
    });

    test('uses empty state when remote feed has no notifications', () async {
      final repository = _FakeNotificationsRepository(
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
        pushService: _FakePushNotificationService(),
        localStore: _FakeNotificationsLocalStore(),
        autoFetchUnreadCount: false,
      );

      await viewModel.fetchNotifications();

      expect(viewModel.viewState, NotificationsViewState.empty);
      expect(viewModel.notifications, isEmpty);
      expect(viewModel.unreadCount, 0);
    });

    test('uses error state when remote fetch fails without cache', () async {
      final repository = _FakeNotificationsRepository(pages: {})
        ..failGetNotifications = true;
      final viewModel = NotificationsViewModel(
        repository: repository,
        pushService: _FakePushNotificationService(),
        localStore: _FakeNotificationsLocalStore(),
        autoFetchUnreadCount: false,
      );

      await viewModel.fetchNotifications();

      expect(viewModel.viewState, NotificationsViewState.error);
      expect(viewModel.notifications, isEmpty);
      expect(viewModel.errorMessage, isNotNull);
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
        localStore: _FakeNotificationsLocalStore(),
        autoFetchUnreadCount: false,
      );

      await viewModel.fetchNotifications();
      await viewModel.loadMore();

      expect(viewModel.notifications.map((item) => item.id), [1, 2]);
      expect(viewModel.hasMore, isFalse);
    });

    test('marks notification as read after API succeeds', () async {
      final repository = _FakeNotificationsRepository(
        unreadCount: 0,
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
      final localStore = _FakeNotificationsLocalStore();
      final viewModel = NotificationsViewModel(
        repository: repository,
        pushService: _FakePushNotificationService(),
        localStore: localStore,
        autoFetchUnreadCount: false,
      );

      await viewModel.fetchNotifications();
      final result = await viewModel.markAsRead(1);

      expect(result, isTrue);
      expect(viewModel.notifications.single.isRead, isTrue);
      expect(viewModel.unreadCount, 0);
      expect(repository.markReadCount, 1);
      expect(repository.markReadIds, [1]);
      expect(localStore.stored.single.isRead, isTrue);
    });

    test('falls back to local unread count when unread-count API fails', () async {
      final repository = _FakeNotificationsRepository(
        pages: {
          1: NotificationsPage(
            items: [
              _notification(id: 1, isRead: false),
              _notification(id: 2, isRead: true),
            ],
            currentPage: 1,
            pageSize: 20,
            totalCount: 2,
            totalPages: 1,
          ),
        },
      )..failUnreadCount = true;
      final viewModel = NotificationsViewModel(
        repository: repository,
        pushService: _FakePushNotificationService(),
        localStore: _FakeNotificationsLocalStore(),
        autoFetchUnreadCount: false,
      );

      await viewModel.fetchNotifications();
      await viewModel.fetchUnreadCount();

      expect(viewModel.unreadCount, 1);
    });

    test('marks as read locally without rollback when API fails', () async {
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
        localStore: _FakeNotificationsLocalStore(),
        autoFetchUnreadCount: false,
      );

      await viewModel.fetchNotifications();
      final result = await viewModel.markAsRead(1);

      expect(result, isTrue);
      expect(viewModel.notifications.single.isRead, isTrue);
      expect(viewModel.unreadCount, 0);
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
        localStore: _FakeNotificationsLocalStore(),
        autoFetchUnreadCount: false,
      );

      await viewModel.fetchNotifications();
      final result = await viewModel.markAllAsRead();

      expect(result, isTrue);
      expect(viewModel.notifications.every((item) => item.isRead), isTrue);
      expect(viewModel.unreadCount, 0);
      expect(repository.markAllCount, 1);
    });

    test('does not mark all as read locally when API fails', () async {
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
      )..failMarkAll = true;
      final viewModel = NotificationsViewModel(
        repository: repository,
        pushService: _FakePushNotificationService(),
        localStore: _FakeNotificationsLocalStore(),
        autoFetchUnreadCount: false,
      );

      await viewModel.fetchNotifications();
      final result = await viewModel.markAllAsRead();

      expect(result, isFalse);
      expect(viewModel.notifications.every((item) => item.isRead), isFalse);
      expect(viewModel.unreadCount, 2);
      expect(repository.markAllCount, 1);
    });

    test('hides notification after API succeeds', () async {
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
        localStore: _FakeNotificationsLocalStore(),
        autoFetchUnreadCount: false,
      );

      await viewModel.fetchNotifications();
      final result = await viewModel.hideNotification(1);

      expect(result, isTrue);
      expect(viewModel.notifications, isEmpty);
      expect(viewModel.viewState, NotificationsViewState.empty);
      expect(viewModel.unreadCount, 0);
      expect(repository.hideCount, 1);
    });

    test('does not hide notification locally when API fails', () async {
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
      )..failHide = true;
      final viewModel = NotificationsViewModel(
        repository: repository,
        pushService: _FakePushNotificationService(),
        localStore: _FakeNotificationsLocalStore(),
        autoFetchUnreadCount: false,
      );

      await viewModel.fetchNotifications();
      final result = await viewModel.hideNotification(1);

      expect(result, isFalse);
      expect(viewModel.notifications.single.id, 1);
      expect(viewModel.unreadCount, 1);
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
        localStore: _FakeNotificationsLocalStore(),
        autoFetchUnreadCount: false,
      );

      await viewModel.fetchNotifications();
      pushService.add(_notification(id: 9, isRead: false));
      await Future<void>.delayed(Duration.zero);

      expect(viewModel.notifications.single.id, 9);
      expect(viewModel.viewState, NotificationsViewState.loaded);
      expect(viewModel.unreadCount, 5);
    });

    test('uses cached notifications when remote fetch fails', () async {
      final repository = _FakeNotificationsRepository(pages: {})
        ..failGetNotifications = true;
      final localStore = _FakeNotificationsLocalStore([
        _notification(id: 8, isRead: false),
      ]);
      final viewModel = NotificationsViewModel(
        repository: repository,
        pushService: _FakePushNotificationService(),
        localStore: localStore,
        autoFetchUnreadCount: false,
      );

      await viewModel.fetchNotifications();

      expect(viewModel.viewState, NotificationsViewState.loaded);
      expect(viewModel.notifications.single.id, 8);
      expect(viewModel.unreadCount, 1);
    });

    test('updates local cache after hiding notification', () async {
      final localStore = _FakeNotificationsLocalStore();
      final repository = _FakeNotificationsRepository(
        unreadCount: 1,
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
        localStore: localStore,
        autoFetchUnreadCount: false,
      );

      await viewModel.fetchNotifications();
      await viewModel.hideNotification(1);

      expect(localStore.stored.map((item) => item.id), [2]);
      expect(repository.hideCount, 1);
    });

    test('syncs cached notifications into current list after background push', () async {
      final localStore = _FakeNotificationsLocalStore([
        _notification(id: 2, isRead: false),
        _notification(id: 1, isRead: true),
      ]);
      final viewModel = NotificationsViewModel(
        repository: _FakeNotificationsRepository(pages: {}),
        pushService: _FakePushNotificationService(),
        localStore: localStore,
        autoFetchUnreadCount: false,
      );

      await viewModel.syncCachedNotifications();

      expect(viewModel.notifications.map((item) => item.id), [1, 2]);
      expect(viewModel.unreadCount, 1);
      expect(viewModel.viewState, NotificationsViewState.loaded);
    });

    test('local store upsert dedupes and preserves read state', () async {
      final storage = LocalStorage();
      final store = NotificationsLocalStore(storage: storage);

      await store.save([
        _notification(id: 1, isRead: true),
        _notification(id: 2, isRead: false),
      ]);
      await store.upsert(
        _notification(id: 1, isRead: false).copyWith(
          actionUrl: '/jobs/updated',
          createdAt: DateTime.utc(2026, 6, 3),
        ),
      );

      final stored = await store.load();

      expect(stored.map((item) => item.id), [1, 2]);
      expect(stored.first.isRead, isTrue);
      expect(stored.first.actionUrl, '/jobs/updated');
    });

    test('local notification cache is scoped to the current user', () async {
      final storage = LocalStorage();
      final store = NotificationsLocalStore(storage: storage);

      await storage.saveString('userId', 'user-a');
      await store.save([_notification(id: 1)]);

      await storage.clear();
      await storage.saveString('userId', 'user-b');

      expect(await store.load(), isEmpty);

      await store.save([_notification(id: 2)]);

      await storage.clear();
      await storage.saveString('userId', 'user-a');

      expect((await store.load()).single.id, 1);
      expect(
        await storage.getString('cached_notifications_user-a'),
        isNotNull,
      );
      expect(
        await storage.getString('cached_notifications_user-b'),
        isNotNull,
      );
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
    createdAt: DateTime.utc(2026, 6, 2, 16, 30, 0, 100 - id),
    isRead: isRead,
    actionUrl: '/jobs/$id',
  );
}
