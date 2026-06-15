import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../model/notification_model.dart';
import 'notification_identity.dart';
import '../utils/local_storage.dart';

class NotificationsLocalStore {
  static const String _storageKey = 'cached_notifications';
  static const int _maxCachedNotifications = 100;
  final LocalStorage _storage;

  NotificationsLocalStore({LocalStorage? storage})
    : _storage = storage ?? LocalStorage();

  Future<List<NotificationModel>> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(await _storage.scopedKey(_storageKey));
      if (raw == null || raw.isEmpty) return const [];

      final decoded = jsonDecode(raw);
      if (decoded is! List) return const [];

      return dedupeNotifications(
        decoded.whereType<Map<String, dynamic>>().map(
          NotificationModel.fromJson,
        ),
      );
    } catch (e) {
      debugPrint('=== NOTIFICATIONS CACHE LOAD ERROR: $e ===');
      return const [];
    }
  }

  Future<void> save(List<NotificationModel> notifications) async {
    try {
      final deduped = dedupeNotifications(
        notifications,
      ).take(_maxCachedNotifications);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        await _storage.scopedKey(_storageKey),
        jsonEncode(deduped.map((item) => item.toJson()).toList()),
      );
    } catch (e) {
      debugPrint('=== NOTIFICATIONS CACHE SAVE ERROR: $e ===');
    }
  }

  Future<void> upsert(NotificationModel notification) async {
    final notifications = await load();
    final existingIndex = notifications.indexWhere(
      (item) => notificationsRepresentSameEvent(item, notification),
    );
    if (existingIndex == -1) {
      await save([notification, ...notifications]);
      return;
    }

    final merged = mergeNotificationModels(
      existing: notifications[existingIndex],
      incoming: notification,
    );
    final updated = List<NotificationModel>.from(notifications)
      ..[existingIndex] = merged;
    await save(updated);
  }
}
