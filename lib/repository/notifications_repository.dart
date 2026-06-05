import 'package:flutter/foundation.dart';

import '../core/constants/api_constants.dart';
import '../model/notification_model.dart';
import '../utils/api_storage.dart';

class NotificationsRepository {
  final ApiClient _apiClient;

  NotificationsRepository({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient();

  Future<NotificationsPage> getNotifications({
    int pageNumber = 1,
    int pageSize = 20,
  }) async {
    try {
      final endpoint =
          '${ApiConstants.notifications}?pageNumber=$pageNumber&pageSize=$pageSize';
      final response = await _apiClient.get(endpoint);
      return NotificationsPage.fromJson(response);
    } catch (e) {
      debugPrint('=== NOTIFICATIONS: fetch error: $e ===');
      rethrow;
    }
  }

  Future<int> getUnreadCount() async {
    try {
      final response = await _apiClient.get(
        ApiConstants.notificationsUnreadCount,
      );
      final data = response['data'];
      if (data is int) return data;
      if (data is String) return _readInt(data);
      if (data is Map<String, dynamic>) {
        return _readInt(
          data['count'] ?? data['unreadCount'] ?? data['totalCount'],
        );
      }
      return _readInt(
        response['count'] ?? response['unreadCount'] ?? response['totalCount'],
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> markAsRead(int notificationId) async {
    try {
      await _apiClient.put(
        ApiConstants.markNotificationRead(notificationId),
        {},
      );
    } catch (e) {
      debugPrint(
        '=== NOTIFICATIONS: markAsRead PUT error, trying legacy POST: $e ===',
      );
      try {
        await _apiClient.post('Notifications/mark-read/$notificationId', {});
      } catch (fallbackError) {
        debugPrint('=== NOTIFICATIONS: markAsRead error: $fallbackError ===');
        rethrow;
      }
    }
  }

  Future<void> markAllAsRead() async {
    try {
      await _apiClient.put(ApiConstants.markAllNotificationsRead, {});
    } catch (e) {
      debugPrint('=== NOTIFICATIONS: markAllAsRead error: $e ===');
      rethrow;
    }
  }

  Future<void> hideNotification(int notificationId) async {
    try {
      await _apiClient.delete(ApiConstants.hideNotification(notificationId));
    } catch (e) {
      debugPrint('=== NOTIFICATIONS: hideNotification error: $e ===');
      rethrow;
    }
  }

  Future<void> registerDeviceToken({
    required String token,
    required String deviceType,
  }) async {
    try {
      await _apiClient.post(ApiConstants.notificationDeviceTokens, {
        'token': token,
        'deviceType': deviceType,
      });
      debugPrint('=== FCM TOKEN REGISTERED: ${_maskToken(token)} ===');
    } catch (e) {
      debugPrint('=== NOTIFICATIONS: registerDeviceToken error: $e ===');
    }
  }

  Future<void> removeDeviceToken(String token) async {
    try {
      await _apiClient.delete(
        ApiConstants.removeNotificationDeviceToken(token),
      );
      debugPrint('=== FCM TOKEN REMOVED: ${_maskToken(token)} ===');
    } catch (e) {
      debugPrint('=== NOTIFICATIONS: removeDeviceToken error: $e ===');
    }
  }

  Future<void> registerFcmToken(String token) {
    return registerDeviceToken(token: token, deviceType: _deviceType());
  }

  static int _readInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  String _maskToken(String token) {
    if (token.length <= 12) return '***';
    return '${token.substring(0, 6)}...${token.substring(token.length - 6)}';
  }

  String _deviceType() {
    if (kIsWeb) return 'web';
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'android';
      case TargetPlatform.iOS:
        return 'ios';
      default:
        return defaultTargetPlatform.name.toLowerCase();
    }
  }
}
