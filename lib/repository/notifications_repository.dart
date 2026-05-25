import 'package:flutter/foundation.dart';
import '../core/constants/api_constants.dart';
import '../model/notification_model.dart';
import '../utils/api_storage.dart';

/// Handles all API communication related to notifications.
/// Responsible for: fetching notifications, marking as read, and sending FCM token.
class NotificationsRepository {
  final ApiClient _apiClient;

  NotificationsRepository({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient();

  /// Fetches the list of notifications from the backend.
  Future<List<NotificationModel>> getNotifications() async {
    try {
      final response = await _apiClient.get(ApiConstants.notifications);
      final rawList = _extractList(response);
      return rawList
          .map(
            (json) => NotificationModel.fromJson(json as Map<String, dynamic>),
          )
          .toList();
    } catch (e) {
      debugPrint('=== NOTIFICATIONS: fetch error: $e ===');
      rethrow;
    }
  }

  /// Marks a specific notification as read on the backend.
  Future<void> markAsRead(String notificationId) async {
    try {
      await _apiClient.post(
        '${ApiConstants.markNotificationRead}/$notificationId',
        {},
      );
    } catch (e) {
      debugPrint('=== NOTIFICATIONS: markAsRead error: $e ===');
      rethrow;
    }
  }

  /// Registers the device FCM token with the backend so it can target this user.
  Future<void> registerFcmToken(String token) async {
    try {
      await _apiClient.post(ApiConstants.registerFcmToken, {'token': token});
      debugPrint('=== FCM TOKEN REGISTERED: $token ===');
    } catch (e) {
      // Token registration failure should not block the user — log and continue.
      debugPrint('=== NOTIFICATIONS: registerFcmToken error: $e ===');
    }
  }

  List<dynamic> _extractList(Map<String, dynamic> response) {
    if (response['data'] is List) return response['data'] as List;
    if (response['notifications'] is List) {
      return response['notifications'] as List;
    }
    if (response['items'] is List) return response['items'] as List;
    return [];
  }
}
