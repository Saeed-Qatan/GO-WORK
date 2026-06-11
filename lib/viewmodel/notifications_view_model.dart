import 'dart:async';

import 'package:flutter/material.dart';

import '../model/notification_model.dart';
import '../repository/notifications_repository.dart';
import '../services/job_service.dart';
import '../services/notification_navigation_service.dart';
import '../services/notifications_local_store.dart';
import '../services/push_notification_service.dart';
import '../utils/app_error_parser.dart';
import '../utils/snackbar_service.dart';
import 'session_resettable.dart';

enum NotificationsViewState { initial, loading, loaded, empty, error }

class NotificationsViewModel extends ChangeNotifier
    with WidgetsBindingObserver
    implements SessionResettable {
  static const int _defaultPageSize = 20;

  final NotificationsRepository _repository;
  final PushNotificationService _pushService;
  final NotificationNavigationService _navigationService;
  final NotificationsLocalStore _localStore;
  final bool _autoFetchUnreadCount;

  StreamSubscription<NotificationModel>? _pushSubscription;
  int _sessionVersion = 0;

  List<NotificationModel> _notifications = [];
  List<NotificationModel> get notifications => _notifications;
  List<NotificationModel> get unreadNotifications =>
      _notifications.where((n) => !n.isRead).toList();
  List<NotificationModel> get readNotifications =>
      _notifications.where((n) => n.isRead).toList();

  int _unreadCount = 0;
  int get unreadCount => _unreadCount;

  NotificationsViewState _viewState = NotificationsViewState.initial;
  NotificationsViewState get viewState => _viewState;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  int _currentPage = 0;
  int _totalPages = 1;
  bool _isLoadingMore = false;
  bool get isLoadingMore => _isLoadingMore;
  bool get hasMore => _currentPage < _totalPages;

  NotificationsViewModel({
    NotificationsRepository? repository,
    PushNotificationService? pushService,
    JobService? jobService,
    NotificationNavigationService? navigationService,
    NotificationsLocalStore? localStore,
    bool autoFetchUnreadCount = true,
  }) : _repository = repository ?? NotificationsRepository(),
       _pushService = pushService ?? PushNotificationService(),
       _navigationService =
           navigationService ??
           NotificationNavigationService(jobService: jobService),
       _localStore = localStore ?? NotificationsLocalStore(),
       _autoFetchUnreadCount = autoFetchUnreadCount {
    _subscribeToLiveNotifications();
    unawaited(_loadCachedNotifications());
    if (_autoFetchUnreadCount) {
      unawaited(fetchUnreadCount());
    }
    // Register lifecycle observer so we sync the badge when the app resumes
    // from background (e.g. after a push notification was received while the
    // app was not in the foreground and the stream never fired).
    WidgetsBinding.instance.addObserver(this);
  }

  Future<void> fetchNotifications({bool refresh = false}) async {
    final requestVersion = _sessionVersion;
    if (_viewState == NotificationsViewState.loading && !refresh) return;

    if (_notifications.isEmpty) {
      await _loadCachedNotifications(requestVersion: requestVersion);
    }

    if (requestVersion != _sessionVersion) return;

    if (_notifications.isEmpty) {
      _viewState = NotificationsViewState.loading;
    }
    _errorMessage = null;
    if (refresh) {
      _currentPage = 0;
      _totalPages = 1;
    }
    notifyListeners();

    try {
      final page = await _repository.getNotifications(
        pageNumber: 1,
        pageSize: _defaultPageSize,
      );
      final cached = await _localStore.load();
      if (requestVersion != _sessionVersion) return;
      _notifications = _mergeNotifications(remote: page.items, local: cached);
      _currentPage = page.currentPage;
      _totalPages = page.totalPages;
      _setLoadedState();
      unawaited(_localStore.save(_notifications));
      await fetchUnreadCount(notify: false);
    } catch (e) {
      final cached = await _localStore.load();
      if (requestVersion != _sessionVersion) return;
      if (cached.isNotEmpty) {
        _notifications = cached;
        _unreadCount = cached.where((n) => !n.isRead).length;
        _setLoadedState();
      } else {
        _errorMessage = AppErrorParser.parse(e);
        _viewState = NotificationsViewState.error;
      }
      debugPrint('=== NOTIFICATIONS VM ERROR: $e ===');
    } finally {
      if (requestVersion == _sessionVersion) {
        notifyListeners();
      }
    }
  }

  Future<void> fetchUnreadCount({bool notify = true}) async {
    try {
      _unreadCount = await _repository.getUnreadCount();
      if (notify) notifyListeners();
    } catch (e) {
      _unreadCount = _notifications.where((n) => !n.isRead).length;
      if (notify) notifyListeners();
    }
  }

  Future<void> loadMore() async {
    final requestVersion = _sessionVersion;
    if (_isLoadingMore || !hasMore) return;

    _isLoadingMore = true;
    notifyListeners();

    try {
      final page = await _repository.getNotifications(
        pageNumber: _currentPage + 1,
        pageSize: _defaultPageSize,
      );
      if (requestVersion != _sessionVersion) return;
      _notifications = [..._notifications, ...page.items];
      _notifications = _dedupeAndSort(_notifications);
      _currentPage = page.currentPage;
      _totalPages = page.totalPages;
      _setLoadedState();
      unawaited(_localStore.save(_notifications));
    } catch (e) {
      SnackbarService.showError(AppErrorParser.parse(e));
      debugPrint('=== NOTIFICATIONS LOAD MORE ERROR: $e ===');
    } finally {
      if (requestVersion == _sessionVersion) {
        _isLoadingMore = false;
        notifyListeners();
      }
    }
  }

  Future<bool> markAsRead(int notificationId) async {
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1 && _notifications[index].isRead) return true;

    final previousUnreadCount = _unreadCount;
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWithRead();
      _unreadCount = (_unreadCount - 1).clamp(0, 1 << 31).toInt();
      await _localStore.save(_notifications);
      notifyListeners();
    }

    try {
      await _repository.markAsRead(notificationId);
      await fetchUnreadCount(notify: false);
      notifyListeners();
      return true;
    } catch (e) {
      if (index == -1) {
        _unreadCount = previousUnreadCount;
      }
      debugPrint('=== MARK AS READ ERROR: $e ===');
      return true;
    }
  }

  Future<bool> markAllAsRead() async {
    final unread = _notifications.where((n) => !n.isRead).toList();
    if (unread.isEmpty && _unreadCount == 0) return true;

    try {
      await _repository.markAllAsRead();
      _notifications = _notifications.map((n) => n.copyWithRead()).toList();
      await _localStore.save(_notifications);
      await fetchUnreadCount(notify: false);
      notifyListeners();
      return true;
    } catch (e) {
      SnackbarService.showError(AppErrorParser.parse(e));
      debugPrint('=== MARK ALL AS READ ERROR: $e ===');
      return false;
    }
  }

  Future<bool> hideNotification(int notificationId) async {
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index == -1) return false;

    try {
      await _repository.hideNotification(notificationId);
      _notifications = List<NotificationModel>.from(_notifications)
        ..removeAt(index);
      _setLoadedState();
      await _localStore.save(_notifications);
      await fetchUnreadCount(notify: false);
      notifyListeners();
      return true;
    } catch (e) {
      SnackbarService.showError(AppErrorParser.parse(e));
      debugPrint('=== HIDE NOTIFICATION ERROR: $e ===');
      return false;
    }
  }

  Future<void> openNotification(
    BuildContext context,
    NotificationModel notification,
  ) async {
    await markAsRead(notification.id);
    if (!context.mounted) return;

    final actionUrl = notification.actionUrl?.trim();
    if (actionUrl == null || actionUrl.isEmpty) return;

    try {
      final opened = await _navigationService.openActionUrl(
        actionUrl,
        context: context,
        replace: false,
      );
      if (!opened) {
        SnackbarService.showError('تعذر فتح الإشعار');
      }
    } catch (e) {
      SnackbarService.showError(AppErrorParser.parse(e));
      debugPrint('=== NOTIFICATION ACTION ERROR: $e ===');
    }
  }

  Future<void> syncCachedNotifications({bool notify = true}) async {
    final cached = await _localStore.load();
    if (cached.isEmpty) return;

    _notifications = _mergeNotifications(remote: _notifications, local: cached);
    _unreadCount = _notifications.where((n) => !n.isRead).length;
    _setLoadedState();
    if (notify) notifyListeners();
  }

  void _subscribeToLiveNotifications() {
    _pushSubscription = _pushService.onNotificationReceived.listen((
      notification,
    ) {
      final alreadyExists = _notifications.any((n) => n.id == notification.id);
      if (!alreadyExists) {
        _notifications = _dedupeAndSort([notification, ..._notifications]);
        // [FIX] Increment locally and immediately. Do NOT call fetchUnreadCount()
        // here — the server hasn't persisted the notification yet, so an API
        // fetch would return the old count and silently undo this +1.
        _unreadCount += notification.isRead ? 0 : 1;
      } else {
        _notifications = _notifications
            .map(
              (item) => item.id == notification.id
                  ? _mergeNotification(existing: item, incoming: notification)
                  : item,
            )
            .toList();
      }
      _setLoadedState();
      unawaited(_localStore.save(_notifications));
      notifyListeners();
      debugPrint(
        '=== VM: Live notification received — local count now: $_unreadCount title: ${notification.title} ===',
      );
    });
  }

  void _setLoadedState() {
    _viewState = _notifications.isEmpty
        ? NotificationsViewState.empty
        : NotificationsViewState.loaded;
  }

  Future<void> _loadCachedNotifications({int? requestVersion}) async {
    final cached = await _localStore.load();
    if (requestVersion != null && requestVersion != _sessionVersion) return;
    if (cached.isEmpty || _notifications.isNotEmpty) return;

    _notifications = cached;
    _unreadCount = cached.where((n) => !n.isRead).length;
    _setLoadedState();
    notifyListeners();
  }

  List<NotificationModel> _mergeNotifications({
    required List<NotificationModel> remote,
    required List<NotificationModel> local,
  }) {
    final byId = <int, NotificationModel>{};
    for (final notification in local) {
      byId[notification.id] = notification;
    }
    for (final notification in remote) {
      final existing = byId[notification.id];
      byId[notification.id] = existing == null
          ? notification
          : _mergeNotification(existing: existing, incoming: notification);
    }
    return _dedupeAndSort(byId.values);
  }

  NotificationModel _mergeNotification({
    required NotificationModel existing,
    required NotificationModel incoming,
  }) {
    return incoming.copyWith(
      isRead: existing.isRead || incoming.isRead,
      actionUrl: incoming.actionUrl ?? existing.actionUrl,
      imageUrl: incoming.imageUrl ?? existing.imageUrl,
    );
  }

  List<NotificationModel> _dedupeAndSort(Iterable<NotificationModel> items) {
    final byId = <int, NotificationModel>{};
    for (final item in items) {
      byId[item.id] = item;
    }
    return byId.values.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  /// Called by the Flutter framework when the app lifecycle state changes.
  ///
  /// On [AppLifecycleState.resumed]: the app has returned from background.
  /// A push notification may have arrived while the app was suspended, and
  /// the FCM stream never fired for that message. Fetching the server count
  /// here guarantees the badge reflects the true unread total immediately.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      debugPrint('=== VM: App resumed — syncing unread count from server ===');
      unawaited(fetchUnreadCount());
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pushSubscription?.cancel();
    super.dispose();
  }

  @override
  void resetSessionState({bool notify = true}) {
    _sessionVersion++;
    _notifications = [];
    _unreadCount = 0;
    _viewState = NotificationsViewState.initial;
    _errorMessage = null;
    _currentPage = 0;
    _totalPages = 1;
    _isLoadingMore = false;
    if (notify) notifyListeners();
  }
}
