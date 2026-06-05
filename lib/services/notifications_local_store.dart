import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../model/notification_model.dart';

class NotificationsLocalStore {
  static const String _storageKey = 'cached_notifications';
  static const int _maxCachedNotifications = 100;

  Future<List<NotificationModel>> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_storageKey);
      if (raw == null || raw.isEmpty) return const [];

      final decoded = jsonDecode(raw);
      if (decoded is! List) return const [];

      return decoded
          .whereType<Map<String, dynamic>>()
          .map(NotificationModel.fromJson)
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } catch (e) {
      debugPrint('=== NOTIFICATIONS CACHE LOAD ERROR: $e ===');
      return const [];
    }
  }

  Future<void> save(List<NotificationModel> notifications) async {
    try {
      final deduped = _dedupe(notifications).take(_maxCachedNotifications);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _storageKey,
        jsonEncode(deduped.map((item) => item.toJson()).toList()),
      );
    } catch (e) {
      debugPrint('=== NOTIFICATIONS CACHE SAVE ERROR: $e ===');
    }
  }

  Future<void> upsert(NotificationModel notification) async {
    final notifications = await load();
    await save([notification, ...notifications]);
  }

  List<NotificationModel> _dedupe(List<NotificationModel> notifications) {
    final byId = <int, NotificationModel>{};
    for (final notification in notifications) {
      byId[notification.id] = notification;
    }
    return byId.values.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }
}
