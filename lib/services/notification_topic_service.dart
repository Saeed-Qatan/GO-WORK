import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

class NotificationTopicService {
  static const String _allTopic = 'all';
  static const String _categoryPrefix = 'category_';

  final FirebaseMessaging _firebaseMessaging;

  NotificationTopicService({FirebaseMessaging? firebaseMessaging})
    : _firebaseMessaging = firebaseMessaging ?? FirebaseMessaging.instance;

  Future<void> subscribeToAll() async {
    try {
      await _firebaseMessaging.subscribeToTopic(_allTopic);
      debugPrint('=== FCM TOPICS: SUBSCRIBED TO $_allTopic ===');
    } catch (e) {
      debugPrint('=== FCM TOPICS: SUBSCRIBE ALL ERROR: $e ===');
    }
  }

  Future<void> subscribeToCategory(String categoryId) async {
    final topic = _categoryTopic(categoryId);
    if (topic == null) {
      debugPrint('=== FCM TOPICS: SKIPPED EMPTY CATEGORY SUBSCRIBE ===');
      return;
    }

    try {
      await _firebaseMessaging.subscribeToTopic(topic);
      debugPrint('=== FCM TOPICS: SUBSCRIBED TO $topic ===');
    } catch (e) {
      debugPrint('=== FCM TOPICS: CATEGORY SUBSCRIBE ERROR ($topic): $e ===');
    }
  }

  Future<void> unsubscribeFromCategory(String categoryId) async {
    final topic = _categoryTopic(categoryId);
    if (topic == null) {
      debugPrint('=== FCM TOPICS: SKIPPED EMPTY CATEGORY UNSUBSCRIBE ===');
      return;
    }

    try {
      await _firebaseMessaging.unsubscribeFromTopic(topic);
      debugPrint('=== FCM TOPICS: UNSUBSCRIBED FROM $topic ===');
    } catch (e) {
      debugPrint('=== FCM TOPICS: CATEGORY UNSUBSCRIBE ERROR ($topic): $e ===');
    }
  }

  Future<void> subscribeUserTopics({required String? categoryId}) async {
    await subscribeToAll();

    final trimmedCategoryId = categoryId?.trim();
    if (trimmedCategoryId == null || trimmedCategoryId.isEmpty) {
      debugPrint('=== FCM TOPICS: NO CATEGORY TOPIC TO SUBSCRIBE ===');
      return;
    }

    await subscribeToCategory(trimmedCategoryId);
  }

  String? _categoryTopic(String categoryId) {
    final trimmedCategoryId = categoryId.trim();
    if (trimmedCategoryId.isEmpty) return null;
    return '$_categoryPrefix$trimmedCategoryId';
  }
}
