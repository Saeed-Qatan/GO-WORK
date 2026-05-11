import 'dart:async';
import 'package:flutter/foundation.dart';
import '../model/notification_model.dart';
import '../repository/notifications_repository.dart';
import '../services/push_notification_service.dart';

enum NotificationsViewState { initial, loading, loaded, empty, error }

/// ViewModel for the Notifications feature.
/// Manages: list of notifications, unread count, loading state,
/// and real-time push updates via [PushNotificationService] stream.
class NotificationsViewModel extends ChangeNotifier {
  final NotificationsRepository _repository;
  final PushNotificationService _pushService;

  StreamSubscription<NotificationModel>? _pushSubscription;

  List<NotificationModel> _notifications = [];
  List<NotificationModel> get notifications => _notifications;

  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  NotificationsViewState _viewState = NotificationsViewState.initial;
  NotificationsViewState get viewState => _viewState;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  NotificationsViewModel({
    NotificationsRepository? repository,
    PushNotificationService? pushService,
  }) : _repository = repository ?? NotificationsRepository(),
       _pushService = pushService ?? PushNotificationService() {
    _subscribeToLiveNotifications();
  }

  // ────────────────────────────────────────────────────
  // Public Methods
  // ────────────────────────────────────────────────────

  /// Fetches all notifications from the backend.
  Future<void> fetchNotifications() async {
    _viewState = NotificationsViewState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _notifications = await _repository.getNotifications();
      _viewState = _notifications.isEmpty
          ? NotificationsViewState.empty
          : NotificationsViewState.loaded;
    } catch (e) {
      _errorMessage = 'فشل في تحميل الإشعارات: $e';
      _viewState = NotificationsViewState.error;
      debugPrint('=== NOTIFICATIONS VM ERROR: $e ===');
    } finally {
      notifyListeners();
    }
  }

  /// Marks a single notification as read locally (optimistic update) and syncs with backend.
  Future<void> markAsRead(String notificationId) async {
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index == -1 || _notifications[index].isRead) return;

    // Optimistic local update — apply immediately for snappy UI
    _notifications[index] = _notifications[index].copyWithRead();
    notifyListeners();

    try {
      await _repository.markAsRead(notificationId);
    } catch (e) {
      // If the backend call fails, revert the optimistic update
      _notifications[index] = _notifications[index];
      debugPrint('=== MARK AS READ ERROR: $e ===');
      notifyListeners();
    }
  }

  /// Marks all notifications as read.
  Future<void> markAllAsRead() async {
    final unread = _notifications.where((n) => !n.isRead).toList();
    if (unread.isEmpty) return;

    // Optimistic local update
    _notifications = _notifications.map((n) => n.copyWithRead()).toList();
    notifyListeners();

    for (final notification in unread) {
      try {
        await _repository.markAsRead(notification.id);
      } catch (e) {
        debugPrint('=== MARK ALL AS READ ERROR for ${notification.id}: $e ===');
      }
    }
  }

  // ────────────────────────────────────────────────────
  // Private Methods
  // ────────────────────────────────────────────────────

  /// Subscribes to the live push notification stream from [PushNotificationService].
  /// When a new notification arrives, it is prepended to the list in real-time.
  void _subscribeToLiveNotifications() {
    _pushSubscription = _pushService.onNotificationReceived.listen((
      notification,
    ) {
      _notifications = [notification, ..._notifications];
      if (_viewState == NotificationsViewState.empty) {
        _viewState = NotificationsViewState.loaded;
      }
      notifyListeners();
      debugPrint(
        '=== VM: New live notification received: ${notification.title} ===',
      );
    });
  }

  @override
  void dispose() {
    _pushSubscription?.cancel();
    super.dispose();
  }
}
