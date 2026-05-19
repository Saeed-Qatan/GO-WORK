import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

class NotificationTopicService {
  static const String _allTopic = 'all';
  static const String _categoryPrefix = 'category_';
  static const Duration _topicOperationTimeout = Duration(seconds: 10);

  final FirebaseMessaging? _firebaseMessaging;

  NotificationTopicService({FirebaseMessaging? firebaseMessaging})
    : _firebaseMessaging = firebaseMessaging;

  Future<void> subscribeToAll() async {
    try {
      await _messaging
          .subscribeToTopic(_allTopic)
          .timeout(_topicOperationTimeout);
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
      await _messaging.subscribeToTopic(topic).timeout(_topicOperationTimeout);
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
      await _messaging
          .unsubscribeFromTopic(topic)
          .timeout(_topicOperationTimeout);
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

  FirebaseMessaging get _messaging =>
      _firebaseMessaging ?? FirebaseMessaging.instance;
}
