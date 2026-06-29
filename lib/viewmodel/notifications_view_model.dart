import 'dart:async';

import 'package:flutter/material.dart';

import '../model/notification_model.dart';
import '../repository/notifications_repository.dart';
import '../services/job_service.dart';
import '../services/notification_identity.dart';
import '../services/notification_navigation_service.dart';
import '../services/notifications_local_store.dart';
import '../services/push_notification_service.dart';
import '../utils/app_error_parser.dart';
import '../utils/session_guard.dart';
import '../utils/snackbar_service.dart';
import 'session_resettable.dart';

enum NotificationsViewState { initial, loading, loaded, empty, error }

class NotificationsViewModel extends ChangeNotifier
    with WidgetsBindingObserver
    implements SessionResettable {
  static const int _defaultPageSize = 20;
  static const Duration _pendingReadCountAdjustmentTtl = Duration(minutes: 2);

  final NotificationsRepository _repository;
  final PushNotificationService _pushService;
  final NotificationNavigationService _navigationService;
  final NotificationsLocalStore _localStore;
  final SessionGuard _sessionGuard;
  final bool _autoFetchUnreadCount;

  StreamSubscription<NotificationModel>? _pushSubscription;
  int _sessionVersion = 0;
  final Set<int> _apiNotificationIds = <int>{};
  final Set<int> _pendingReadNotificationIds = <int>{};
  final List<NotificationModel> _pendingReadNotifications =
      <NotificationModel>[];
  DateTime? _pendingReadUpdatedAt;

  List<NotificationModel> _notifications = [];
  List<NotificationModel> get notifications => _notifications;
  List<NotificationModel> _unreadNotifications = [];
  List<NotificationModel> get unreadNotifications => _unreadNotifications;
  List<NotificationModel> _readNotifications = [];
  List<NotificationModel> get readNotifications => _readNotifications;

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
    SessionGuard? sessionGuard,
    bool autoFetchUnreadCount = true,
  }) : _repository = repository ?? NotificationsRepository(),
       _pushService = pushService ?? PushNotificationService(),
       _navigationService =
           navigationService ??
           NotificationNavigationService(jobService: jobService),
       _localStore = localStore ?? NotificationsLocalStore(),
       _sessionGuard = sessionGuard ?? SessionGuard(),
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
      _apiNotificationIds
        ..clear()
        ..addAll(page.items.map((notification) => notification.id));
      _logMergeInputs(remote: page.items, local: cached);
      _setNotifications(_mergeNotifications(remote: page.items, local: cached));
      _currentPage = page.currentPage;
      _totalPages = page.totalPages;
      _setLoadedState();
      unawaited(_localStore.save(_notifications));
      await _syncReadStateToApi(remote: page.items, local: cached);
      await fetchUnreadCount(notify: false);
    } catch (e) {
      final cached = await _localStore.load();
      if (requestVersion != _sessionVersion) return;
      if (cached.isNotEmpty) {
        _setNotifications(cached);
        _unreadCount = _unreadNotifications.length;
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
    if (!await _sessionGuard.hasActiveToken()) {
      _unreadCount = _unreadNotifications.length;
      if (notify) notifyListeners();
      debugPrint(
        '=== VM: Skipped unread-count sync because no auth token exists ===',
      );
      return;
    }

    try {
      final serverUnreadCount = await _repository.getUnreadCount();
      _unreadCount = _resolveUnreadCount(serverUnreadCount);
      if (notify) notifyListeners();
    } catch (e) {
      _unreadCount = _unreadNotifications.length;
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
      _apiNotificationIds.addAll(
        page.items.map((notification) => notification.id),
      );
      _setNotifications(_dedupeAndSort([..._notifications, ...page.items]));
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
    debugPrint('=== VM: markAsRead triggered for id=$notificationId ===');

    // If notifications list is currently empty, ensure cache is fully loaded first
    // to prevent race conditions when app launches by tapping a notification.
    if (_notifications.isEmpty) {
      debugPrint(
        '=== VM: markAsRead: notifications list is empty, awaiting cache load... ===',
      );
      await _loadCachedNotifications();
    }

    final target = _findNotification(notificationId);
    if (target == null) {
      _rememberPendingRead(notificationId: notificationId);
      // Immediate visual update to decrease unread count badge in current UI state
      debugPrint(
        '=== VM: markAsRead: target not found. Decrementing count locally ===',
      );
      if (_unreadCount > 0) {
        _unreadCount--;
        notifyListeners();
      }

      try {
        await _repository.markAsRead(notificationId);
        await fetchUnreadCount(notify: false);
        notifyListeners();
      } catch (e) {
        debugPrint('=== MARK AS READ ERROR: $e ===');
      }
      return true;
    }

    return markNotificationAsRead(target);
  }

  Future<bool> markNotificationAsRead(NotificationModel notification) async {
    debugPrint(
      '=== VM: markNotificationAsRead triggered for '
      '${notificationDebugIdentity(notification)} ===',
    );

    _rememberPendingRead(notification: notification);

    if (_notifications.isEmpty) {
      debugPrint(
        '=== VM: markNotificationAsRead: notifications list is empty, awaiting cache load... ===',
      );
      await _loadCachedNotifications();
    }

    final target = _findMatchingNotification(notification) ?? notification;
    final matchingIndexes = _matchingIndexes(target);
    if (matchingIndexes.isNotEmpty &&
        matchingIndexes.every((index) => _notifications[index].isRead)) {
      return _markApiBackedNotificationReadIfNeeded(target);
    }

    final unreadMatches = matchingIndexes
        .where((index) => !_notifications[index].isRead)
        .length;
    if (matchingIndexes.isNotEmpty) {
      final updated = List<NotificationModel>.from(_notifications);
      for (final index in matchingIndexes) {
        updated[index] = updated[index].copyWithRead();
      }
      _setNotifications(_dedupeAndSort(updated));
      _unreadCount = (_unreadCount - unreadMatches).clamp(0, 1 << 31).toInt();
      await _localStore.save(_notifications);
      notifyListeners();
    } else if (!target.isRead) {
      _setNotifications(
        _dedupeAndSort([target.copyWithRead(), ..._notifications]),
      );
      if (_unreadCount > 0) {
        _unreadCount--;
      }
      await _localStore.save(_notifications);
      notifyListeners();
    }

    return _markApiBackedNotificationReadIfNeeded(target);
  }

  Future<bool> _markApiBackedNotificationReadIfNeeded(
    NotificationModel target,
  ) async {
    final apiNotification = _apiBackedMatchFor(target);
    if (apiNotification == null) {
      debugPrint(
        '=== MARK AS READ: local-only notification marked read without API call '
        '${notificationDebugIdentity(target)} ===',
      );
      return true;
    }

    try {
      await _repository.markAsRead(apiNotification.id);
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('=== MARK AS READ ERROR: $e ===');
      return true;
    }
  }

  Future<bool> markAllAsRead() async {
    if (_unreadNotifications.isEmpty && _unreadCount == 0) return true;

    try {
      await _repository.markAllAsRead();
      _setNotifications(_notifications.map((n) => n.copyWithRead()).toList());
      _pendingReadNotificationIds.clear();
      _pendingReadNotifications.clear();
      await _localStore.save(_notifications);
      _unreadCount = 0;
      notifyListeners();
      return true;
    } catch (e) {
      SnackbarService.showError(AppErrorParser.parse(e));
      debugPrint('=== MARK ALL AS READ ERROR: $e ===');
      return false;
    }
  }

  Future<bool> hideNotification(int notificationId) async {
    final target = _findNotification(notificationId);
    if (target == null) return false;

    final apiNotification = _apiBackedMatchFor(target);
    final apiNotificationId = apiNotification?.id ?? notificationId;

    try {
      if (apiNotification != null) {
        await _repository.hideNotification(apiNotificationId);
      } else {
        debugPrint(
          '=== HIDE NOTIFICATION: local-only notification removed without API call '
          '${notificationDebugIdentity(target)} ===',
        );
      }
      _setNotifications(
        _notifications
            .where((item) => !notificationsRepresentSameEvent(item, target))
            .toList(),
      );
      _setLoadedState();
      await _localStore.save(_notifications);
      if (apiNotification != null) {
        await fetchUnreadCount(notify: false);
      } else {
        _unreadCount = _unreadNotifications.length;
      }
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
    await markNotificationAsRead(notification);
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

    _setNotifications(
      _mergeNotifications(remote: _notifications, local: cached),
    );
    _unreadCount = _unreadNotifications.length;
    _setLoadedState();
    if (notify) notifyListeners();
  }

  void _subscribeToLiveNotifications() {
    _pushSubscription = _pushService.onNotificationReceived.listen((
      notification,
    ) {
      debugPrint(
        '=== VM: Live notification received ${notificationDebugIdentity(notification)} ===',
      );
      final alreadyExists = _notifications.any(
        (n) => notificationsRepresentSameEvent(n, notification),
      );
      if (!alreadyExists) {
        _setNotifications(_dedupeAndSort([notification, ..._notifications]));
        // [FIX] Increment locally and immediately. Do NOT call fetchUnreadCount()
        // here — the server hasn't persisted the notification yet, so an API
        // fetch would return the old count and silently undo this +1.
        _unreadCount += notification.isRead ? 0 : 1;
      } else {
        _setNotifications(
          _dedupeAndSort(
            _notifications.map(
              (item) => notificationsRepresentSameEvent(item, notification)
                  ? mergeNotificationModels(
                      existing: item,
                      incoming: notification,
                    )
                  : item,
            ),
          ),
        );
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

    _setNotifications(cached);
    _unreadCount = _unreadNotifications.length;
    _setLoadedState();
    notifyListeners();
  }

  List<NotificationModel> _mergeNotifications({
    required List<NotificationModel> remote,
    required List<NotificationModel> local,
  }) {
    return _dedupeAndSort([...local, ...remote]);
  }

  List<NotificationModel> _dedupeAndSort(Iterable<NotificationModel> items) {
    return dedupeNotifications(items);
  }

  void _setNotifications(List<NotificationModel> notifications) {
    final updated = notifications.map((n) {
      if (_hasPendingReadFor(n) && !n.isRead) {
        return n.copyWithRead();
      }
      return n;
    }).toList();
    _notifications = updated;
    _unreadNotifications = updated.where((n) => !n.isRead).toList();
    _readNotifications = updated.where((n) => n.isRead).toList();
  }

  NotificationModel? _findNotification(int notificationId) {
    for (final notification in _notifications) {
      if (_matchesNotificationId(notification, notificationId)) {
        return notification;
      }
    }
    return null;
  }

  NotificationModel? _findMatchingNotification(NotificationModel target) {
    for (final notification in _notifications) {
      if (notificationsRepresentSameEvent(notification, target)) {
        return notification;
      }
    }
    return null;
  }

  List<int> _matchingIndexes(NotificationModel target) {
    final indexes = <int>[];
    for (var i = 0; i < _notifications.length; i++) {
      if (notificationsRepresentSameEvent(_notifications[i], target)) {
        indexes.add(i);
      }
    }
    return indexes;
  }

  NotificationModel? _apiBackedMatchFor(NotificationModel target) {
    for (final notification in _notifications) {
      if (notificationsRepresentSameEvent(notification, target) &&
          _isApiBackedNotification(notification)) {
        return notification;
      }
    }
    return _isApiBackedNotification(target) ? target : null;
  }

  bool _isApiBackedNotification(NotificationModel notification) {
    return _apiNotificationIds.contains(notification.id) ||
        isApiBackedNotification(notification);
  }

  void _rememberPendingRead({
    NotificationModel? notification,
    int? notificationId,
  }) {
    if (notificationId != null) {
      _pendingReadNotificationIds.add(notificationId);
    }

    if (notification == null) {
      if (notificationId != null) {
        _pendingReadUpdatedAt = DateTime.now();
      }
      return;
    }

    _pendingReadNotificationIds.add(notification.id);
    final backendNotificationId = notification.notificationId;
    if (backendNotificationId != null) {
      _pendingReadNotificationIds.add(backendNotificationId);
    }

    final alreadyTracked = _pendingReadNotifications.any(
      (item) => notificationsRepresentSameEvent(item, notification),
    );
    if (!alreadyTracked) {
      _pendingReadNotifications.add(notification.copyWithRead());
    }

    _pendingReadUpdatedAt = DateTime.now();
  }

  bool _hasPendingReadFor(NotificationModel notification) {
    if (_pendingReadNotificationIds.any(
      (id) => _matchesNotificationId(notification, id),
    )) {
      return true;
    }

    return _pendingReadNotifications.any(
      (item) => notificationsRepresentSameEvent(item, notification),
    );
  }

  bool _matchesNotificationId(NotificationModel notification, int id) {
    return notification.id == id || notification.notificationId == id;
  }

  int _resolveUnreadCount(int serverUnreadCount) {
    final pendingReadCount = _activePendingReadCount();
    if (pendingReadCount == 0) return serverUnreadCount;

    final adjustedServerCount = serverUnreadCount > _unreadCount
        ? (serverUnreadCount - pendingReadCount).clamp(0, 1 << 31).toInt()
        : serverUnreadCount;
    final localUnreadCount = _unreadNotifications.length;
    return adjustedServerCount < localUnreadCount
        ? localUnreadCount
        : adjustedServerCount;
  }

  int _activePendingReadCount() {
    final pendingReadUpdatedAt = _pendingReadUpdatedAt;
    if (pendingReadUpdatedAt == null ||
        DateTime.now().difference(pendingReadUpdatedAt) >
            _pendingReadCountAdjustmentTtl) {
      _pendingReadNotificationIds.clear();
      _pendingReadNotifications.clear();
      _pendingReadUpdatedAt = null;
      return 0;
    }

    var count = _pendingReadNotifications.length;
    for (final id in _pendingReadNotificationIds) {
      final representedByNotification = _pendingReadNotifications.any(
        (notification) => _matchesNotificationId(notification, id),
      );
      if (!representedByNotification) {
        count++;
      }
    }
    return count;
  }

  Future<void> _syncReadStateToApi({
    required List<NotificationModel> remote,
    required List<NotificationModel> local,
  }) async {
    final apiIdsToMark = <int>{};

    for (final remoteNotification in remote) {
      if (remoteNotification.isRead) continue;

      final hasReadLocalCopy = local.any(
        (localNotification) =>
            localNotification.isRead &&
            notificationsRepresentSameEvent(
              localNotification,
              remoteNotification,
            ),
      );
      final hasPendingRead = _hasPendingReadFor(remoteNotification);

      if (hasReadLocalCopy || hasPendingRead) {
        apiIdsToMark.add(remoteNotification.id);
      }
    }

    if (apiIdsToMark.isEmpty) return;

    for (final id in apiIdsToMark) {
      try {
        await _repository.markAsRead(id);
      } catch (e) {
        debugPrint('=== PENDING MARK AS READ SYNC ERROR: id=$id error=$e ===');
      }
    }
  }

  void _logMergeInputs({
    required List<NotificationModel> remote,
    required List<NotificationModel> local,
  }) {
    for (final notification in local) {
      debugPrint(
        '=== NOTIFICATIONS MERGE LOCAL ${notificationDebugIdentity(notification)} ===',
      );
    }
    for (final notification in remote) {
      debugPrint(
        '=== NOTIFICATIONS MERGE API ${notificationDebugIdentity(notification)} ===',
      );
    }
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
    _setNotifications([]);
    _apiNotificationIds.clear();
    _pendingReadNotificationIds.clear();
    _pendingReadNotifications.clear();
    _pendingReadUpdatedAt = null;
    _unreadCount = 0;
    _viewState = NotificationsViewState.initial;
    _errorMessage = null;
    _currentPage = 0;
    _totalPages = 1;
    _isLoadingMore = false;
    if (notify) notifyListeners();
  }
}
