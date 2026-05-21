import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

abstract class TopicMessaging {
  Future<void> subscribeToTopic(String topic);

  Future<void> unsubscribeFromTopic(String topic);
}

class FirebaseTopicMessaging implements TopicMessaging {
  final FirebaseMessaging _messaging;

  FirebaseTopicMessaging({FirebaseMessaging? firebaseMessaging})
    : _messaging = firebaseMessaging ?? FirebaseMessaging.instance;

  @override
  Future<void> subscribeToTopic(String topic) {
    return _messaging.subscribeToTopic(topic);
  }

  @override
  Future<void> unsubscribeFromTopic(String topic) {
    return _messaging.unsubscribeFromTopic(topic);
  }
}

class NotificationTopicService {
  static const String _allTopic = 'all';
  static const String _categoryPrefix = 'category_';
  static const Duration _topicOperationTimeout = Duration(seconds: 10);

  final TopicMessaging _topicMessaging;

  NotificationTopicService({
    FirebaseMessaging? firebaseMessaging,
    TopicMessaging? topicMessaging,
  }) : _topicMessaging =
           topicMessaging ??
           FirebaseTopicMessaging(firebaseMessaging: firebaseMessaging);

  Future<void> subscribeToAll() async {
    try {
      await _topicMessaging
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
      await _topicMessaging
          .subscribeToTopic(topic)
          .timeout(_topicOperationTimeout);
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
      await _topicMessaging
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
    debugPrint(
      '=== FCM TOPICS DEBUG: CATEGORY ID = ${trimmedCategoryId?.isNotEmpty == true ? trimmedCategoryId : 'EMPTY'} ===',
    );
    if (trimmedCategoryId == null || trimmedCategoryId.isEmpty) {
      debugPrint('=== FCM TOPICS: NO CATEGORY TOPIC TO SUBSCRIBE ===');
      return;
    }

    await subscribeToCategory(trimmedCategoryId);
  }

  Future<void> syncUserTopics({
    required String? previousCategoryId,
    required String? categoryId,
  }) async {
    await subscribeToAll();

    final previous = _normalizeCategoryId(previousCategoryId);
    final current = _normalizeCategoryId(categoryId);

    debugPrint(
      '=== FCM TOPICS DEBUG: PREVIOUS CATEGORY ID = ${previous ?? 'EMPTY'}, CURRENT CATEGORY ID = ${current ?? 'EMPTY'} ===',
    );

    if (previous == current) {
      debugPrint('=== FCM TOPICS: CATEGORY TOPIC UNCHANGED ===');
      return;
    }

    if (current != null) {
      await subscribeToCategory(current);
    } else {
      debugPrint('=== FCM TOPICS: NO CATEGORY TOPIC TO SUBSCRIBE ===');
    }

    if (previous != null) {
      await unsubscribeFromCategory(previous);
    }
  }

  String? _normalizeCategoryId(String? categoryId) {
    final trimmedCategoryId = categoryId?.trim();
    if (trimmedCategoryId == null || trimmedCategoryId.isEmpty) return null;
    return trimmedCategoryId;
  }

  String? _categoryTopic(String categoryId) {
    final trimmedCategoryId = categoryId.trim();
    if (trimmedCategoryId.isEmpty) return null;
    final topic = '$_categoryPrefix$trimmedCategoryId';
    debugPrint('=== FCM TOPICS DEBUG: RESOLVED CATEGORY TOPIC = $topic ===');
    return topic;
  }
}
