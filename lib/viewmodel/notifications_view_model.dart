import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../model/notification_model.dart';
import '../repository/notifications_repository.dart';
import '../routing/app_router.dart';
import '../services/job_service.dart';
import '../services/push_notification_service.dart';
import '../utils/app_error_parser.dart';
import '../utils/snackbar_service.dart';

enum NotificationsViewState { initial, loading, loaded, empty, error }

class NotificationsViewModel extends ChangeNotifier {
  static const int _defaultPageSize = 20;

  final NotificationsRepository _repository;
  final PushNotificationService _pushService;
  final JobService _jobService;
  final bool _autoFetchUnreadCount;

  StreamSubscription<NotificationModel>? _pushSubscription;

  List<NotificationModel> _notifications = [];
  List<NotificationModel> get notifications => _notifications;

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
    bool autoFetchUnreadCount = true,
  }) : _repository = repository ?? NotificationsRepository(),
       _pushService = pushService ?? PushNotificationService(),
       _jobService = jobService ?? JobService(),
       _autoFetchUnreadCount = autoFetchUnreadCount {
    _subscribeToLiveNotifications();
    if (_autoFetchUnreadCount) {
      unawaited(fetchUnreadCount());
    }
  }

  Future<void> fetchNotifications({bool refresh = false}) async {
    if (_viewState == NotificationsViewState.loading && !refresh) return;

    _viewState = NotificationsViewState.loading;
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
      _notifications = page.items;
      _currentPage = page.currentPage;
      _totalPages = page.totalPages;
      _setLoadedState();
      await fetchUnreadCount(notify: false);
    } catch (e) {
      _errorMessage = AppErrorParser.parse(e);
      _viewState = NotificationsViewState.error;
      debugPrint('=== NOTIFICATIONS VM ERROR: $e ===');
    } finally {
      notifyListeners();
    }
  }

  Future<void> fetchUnreadCount({bool notify = true}) async {
    try {
      _unreadCount = await _repository.getUnreadCount();
      if (notify) notifyListeners();
    } catch (e) {
      debugPrint('=== NOTIFICATIONS UNREAD COUNT ERROR: $e ===');
    }
  }

  Future<void> loadMore() async {
    if (_isLoadingMore || !hasMore) return;

    _isLoadingMore = true;
    notifyListeners();

    try {
      final page = await _repository.getNotifications(
        pageNumber: _currentPage + 1,
        pageSize: _defaultPageSize,
      );
      _notifications = [..._notifications, ...page.items];
      _currentPage = page.currentPage;
      _totalPages = page.totalPages;
      _setLoadedState();
    } catch (e) {
      SnackbarService.showError(AppErrorParser.parse(e));
      debugPrint('=== NOTIFICATIONS LOAD MORE ERROR: $e ===');
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  Future<void> markAsRead(int notificationId) async {
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index == -1 || _notifications[index].isRead) return;

    final previous = _notifications[index];
    final previousUnreadCount = _unreadCount;
    _notifications[index] = previous.copyWithRead();
    _unreadCount = (_unreadCount - 1).clamp(0, 1 << 31).toInt();
    notifyListeners();

    try {
      await _repository.markAsRead(notificationId);
    } catch (e) {
      _notifications[index] = previous;
      _unreadCount = previousUnreadCount;
      debugPrint('=== MARK AS READ ERROR: $e ===');
      notifyListeners();
    }
  }

  Future<void> markAllAsRead() async {
    final unread = _notifications.where((n) => !n.isRead).toList();
    if (unread.isEmpty && _unreadCount == 0) return;

    final previousNotifications = List<NotificationModel>.from(_notifications);
    final previousUnreadCount = _unreadCount;
    _notifications = _notifications.map((n) => n.copyWithRead()).toList();
    _unreadCount = 0;
    notifyListeners();

    try {
      await _repository.markAllAsRead();
    } catch (e) {
      _notifications = previousNotifications;
      _unreadCount = previousUnreadCount;
      SnackbarService.showError(AppErrorParser.parse(e));
      debugPrint('=== MARK ALL AS READ ERROR: $e ===');
      notifyListeners();
    }
  }

  Future<void> hideNotification(int notificationId) async {
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index == -1) return;

    final removed = _notifications[index];
    final previousUnreadCount = _unreadCount;
    _notifications = List<NotificationModel>.from(_notifications)
      ..removeAt(index);
    if (!removed.isRead) {
      _unreadCount = (_unreadCount - 1).clamp(0, 1 << 31).toInt();
    }
    _setLoadedState();
    notifyListeners();

    try {
      await _repository.hideNotification(notificationId);
    } catch (e) {
      _notifications = List<NotificationModel>.from(_notifications)
        ..insert(index, removed);
      _unreadCount = previousUnreadCount;
      _setLoadedState();
      SnackbarService.showError(AppErrorParser.parse(e));
      debugPrint('=== HIDE NOTIFICATION ERROR: $e ===');
      notifyListeners();
    }
  }

  Future<void> openNotification(
    BuildContext context,
    NotificationModel notification,
  ) async {
    await markAsRead(notification.id);

    final actionUrl = notification.actionUrl?.trim();
    if (actionUrl == null || actionUrl.isEmpty) return;

    final uri = Uri.tryParse(actionUrl);
    final segments = uri?.pathSegments ?? const <String>[];
    if (segments.length == 2 && segments.first.toLowerCase() == 'jobs') {
      if (!context.mounted) return;
      await _openJob(context, segments[1]);
    }
  }

  Future<void> _openJob(BuildContext context, String jobId) async {
    try {
      final job = await _jobService.getJobById(jobId);
      if (job == null) return;
      if (!context.mounted) return;
      context.push(AppRoutes.jobDetails, extra: job);
    } catch (e) {
      SnackbarService.showError(AppErrorParser.parse(e));
      debugPrint('=== NOTIFICATION ACTION JOB ERROR: $e ===');
    }
  }

  void _subscribeToLiveNotifications() {
    _pushSubscription = _pushService.onNotificationReceived.listen((
      notification,
    ) {
      final alreadyExists = _notifications.any((n) => n.id == notification.id);
      if (!alreadyExists) {
        _notifications = [notification, ..._notifications];
        _unreadCount += notification.isRead ? 0 : 1;
      }
      _setLoadedState();
      notifyListeners();
      unawaited(fetchUnreadCount());
      debugPrint(
        '=== VM: New live notification received: ${notification.title} ===',
      );
    });
  }

  void _setLoadedState() {
    _viewState = _notifications.isEmpty
        ? NotificationsViewState.empty
        : NotificationsViewState.loaded;
  }

  @override
  void dispose() {
    _pushSubscription?.cancel();
    super.dispose();
  }
}
