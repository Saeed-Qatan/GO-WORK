import 'package:flutter/foundation.dart';

import '../core/constants/api_constants.dart';
import '../model/notification_model.dart';
import '../utils/api_storage.dart';
import '../utils/app_error_parser.dart';
import '../utils/timezone_utils.dart';

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
      if (e is AppApiException) {
        debugPrint('=== NOTIFICATIONS FETCH ERROR DETAILS: status=${e.statusCode} data=${e.data} ===');
      }
      debugPrint('=== NOTIFICATIONS: fetch error: $e ===');
      rethrow;
    }
  }

  /// Fetches the count of unread and visible notifications for the authenticated user.
  ///
  /// Since backend environments might differ, this method employs a dynamic fallback system.
  /// It attempts multiple combinations of HTTP methods and endpoints:
  /// 1. GET `notifications/unread-count` (Documented API)
  /// 2. GET `notifications/unread` (Alternate path)
  /// 3. POST `notifications/unread-count` (Alternate method)
  /// 4. POST `notifications/unread` (Alternate path & method)
  ///
  /// If a 401 error is encountered, it is immediately rethrown to trigger session expiration logic.
  Future<int> getUnreadCount() async {
    final List<Map<String, String>> candidates = [
      {'method': 'GET', 'path': ApiConstants.notificationsUnreadCount},
      {'method': 'GET', 'path': 'notifications/unread'},
      {'method': 'POST', 'path': ApiConstants.notificationsUnreadCount},
      {'method': 'POST', 'path': 'notifications/unread'},
    ];

    AppApiException? lastException;

    for (final candidate in candidates) {
      final method = candidate['method']!;
      final path = candidate['path']!;
      debugPrint('=== UNREADCOUNT TRYING: method=$method path="$path" fullUrl="${ApiConstants.baseUrl}$path" ===');
      try {
        final Map<String, dynamic> response;
        if (method == 'GET') {
          response = await _apiClient.get(path);
        } else {
          response = await _apiClient.post(path, {});
        }
        debugPrint('=== UNREADCOUNT SUCCESS: method=$method path="$path" response=$response ===');
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
        debugPrint('=== UNREADCOUNT FAILED: method=$method path="$path" error=$e ===');
        if (e is AppApiException) {
          lastException = e;
          if (e.statusCode == 401) {
            rethrow;
          }
        }
      }
    }

    if (lastException != null) {
      debugPrint('=== NOTIFICATIONS UNREADCOUNT ALL FALLBACKS FAILED. Last error: status=${lastException.statusCode} data=${lastException.data} ===');
      throw lastException;
    }
    throw Exception('Failed to fetch unread count through all endpoints and methods');
  }

  Future<void> markAsRead(int notificationId) async {
    final endpoint = ApiConstants.markNotificationRead(notificationId);
    debugPrint('=== MARKREAD DEBUG: endpoint="$endpoint" method=PUT ===');
    try {
      await _apiClient.put(endpoint, {});
    } catch (e) {
      if (e is AppApiException && e.statusCode == 405) {
        debugPrint('=== MARKREAD: PUT returned 405, trying POST... ===');
        try {
          await _apiClient.post(endpoint, {});
          debugPrint('=== MARKREAD: POST succeeded! ===');
          return;
        } catch (e2) {
          debugPrint('=== MARKREAD: POST also failed: $e2 ===');
        }
      }
      if (e is AppApiException) {
        debugPrint('=== NOTIFICATIONS MARKREAD ERROR DETAILS: status=${e.statusCode} data=${e.data} ===');
      }
      debugPrint('=== NOTIFICATIONS: markAsRead error: $e ===');
      rethrow;
    }
  }

  Future<void> markAllAsRead() async {
    final endpoint = ApiConstants.markAllNotificationsRead;
    debugPrint('=== MARKALLREAD DEBUG: endpoint="$endpoint" fullUrl="${ApiConstants.baseUrl}$endpoint" method=PUT ===');
    try {
      await _apiClient.put(endpoint, {});
    } catch (e) {
      if (e is AppApiException && e.statusCode == 405) {
        debugPrint('=== MARKALLREAD: PUT returned 405, trying POST... ===');
        try {
          await _apiClient.post(endpoint, {});
          debugPrint('=== MARKALLREAD: POST succeeded! ===');
          return;
        } catch (e2) {
          debugPrint('=== MARKALLREAD: POST also failed: $e2 ===');
        }
        debugPrint('=== MARKALLREAD: Trying PATCH... ===');
        try {
          await _apiClient.patch(endpoint, {});
          debugPrint('=== MARKALLREAD: PATCH succeeded! ===');
          return;
        } catch (e3) {
          debugPrint('=== MARKALLREAD: PATCH also failed: $e3 ===');
        }
      }
      if (e is AppApiException) {
        debugPrint('=== NOTIFICATIONS MARKALLREAD ERROR DETAILS: status=${e.statusCode} data=${e.data} ===');
      }
      debugPrint('=== NOTIFICATIONS: markAllAsRead error: $e ===');
      rethrow;
    }
  }

  Future<void> hideNotification(int notificationId) async {
    try {
      await _apiClient.delete(ApiConstants.hideNotification(notificationId));
    } catch (e) {
      if (e is AppApiException) {
        debugPrint('=== NOTIFICATIONS HIDENOTIFICATION ERROR DETAILS: status=${e.statusCode} data=${e.data} ===');
      }
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
        'timeZone': TimezoneUtils.currentTimeZoneName,
        'timezoneOffset': TimezoneUtils.currentTimezoneOffset,
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
