import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import '../core/constants/api_constants.dart';
import '../utils/api_storage.dart';

abstract class TopicMessaging {
  Future<void> subscribeToTopic(String topic);

  Future<void> unsubscribeFromTopic(String topic);
}

class NotificationCategory {
  final String id;
  final String name;

  const NotificationCategory({required this.id, required this.name});
}

class NotificationCategoryResolver {
  final ApiClient _apiClient;
  List<NotificationCategory>? _cachedCategories;

  NotificationCategoryResolver({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient();

  Future<NotificationCategory?> resolveById(String categoryId) async {
    final normalizedId = categoryId.trim();
    if (normalizedId.isEmpty) return null;

    final categories = await _loadCategories();
    for (final category in categories) {
      if (category.id == normalizedId) return category;
    }
    return null;
  }

  Future<List<NotificationCategory>> _loadCategories() async {
    final cached = _cachedCategories;
    if (cached != null) return cached;

    final response = await _apiClient.get(
      ApiConstants.jobCategories,
      skipAuth: true,
    );
    final rawCategories = _readCategoryList(response);
    final categories = rawCategories
        .whereType<Map>()
        .map((item) {
          final id =
              item['id'] ??
              item['Id'] ??
              item['categoryId'] ??
              item['CategoryId'];
          final name =
              item['name'] ??
              item['Name'] ??
              item['categoryName'] ??
              item['CategoryName'];

          return NotificationCategory(
            id: id?.toString().trim() ?? '',
            name: name?.toString().trim() ?? '',
          );
        })
        .where((item) => item.id.isNotEmpty && item.name.isNotEmpty)
        .toList();

    _cachedCategories = categories;
    return categories;
  }

  List<dynamic> _readCategoryList(Map<String, dynamic> response) {
    if (response['data'] is List) return response['data'] as List<dynamic>;
    if (response['categories'] is List) {
      return response['categories'] as List<dynamic>;
    }

    final data = response['data'];
    if (data is Map<String, dynamic> && data['categories'] is List) {
      return data['categories'] as List<dynamic>;
    }

    return const <dynamic>[];
  }
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
  final NotificationCategoryResolver _categoryResolver;

  NotificationTopicService({
    FirebaseMessaging? firebaseMessaging,
    TopicMessaging? topicMessaging,
    NotificationCategoryResolver? categoryResolver,
  }) : _topicMessaging =
           topicMessaging ??
           FirebaseTopicMessaging(firebaseMessaging: firebaseMessaging),
       _categoryResolver = categoryResolver ?? NotificationCategoryResolver();

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
    final topics = await _categoryTopics(categoryId);
    if (topics.isEmpty) {
      debugPrint('=== FCM TOPICS: SKIPPED EMPTY CATEGORY SUBSCRIBE ===');
      return;
    }

    for (final topic in topics) {
      try {
        await _topicMessaging
            .subscribeToTopic(topic)
            .timeout(_topicOperationTimeout);
        debugPrint('=== FCM TOPICS: SUBSCRIBED TO $topic ===');
      } catch (e) {
        debugPrint(
          '=== FCM TOPICS: CATEGORY SUBSCRIBE ERROR ($topic): $e ===',
        );
      }
    }
  }

  Future<void> unsubscribeFromCategory(String categoryId) async {
    final topics = await _categoryTopics(categoryId);
    if (topics.isEmpty) {
      debugPrint('=== FCM TOPICS: SKIPPED EMPTY CATEGORY UNSUBSCRIBE ===');
      return;
    }

    for (final topic in topics) {
      try {
        await _topicMessaging
            .unsubscribeFromTopic(topic)
            .timeout(_topicOperationTimeout);
        debugPrint('=== FCM TOPICS: UNSUBSCRIBED FROM $topic ===');
      } catch (e) {
        debugPrint(
          '=== FCM TOPICS: CATEGORY UNSUBSCRIBE ERROR ($topic): $e ===',
        );
      }
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

  bool _isValidFirebaseTopic(String topic) {
    return RegExp(r'^[a-zA-Z0-9-_.~%]+$').hasMatch(topic);
  }

  Future<List<String>> _categoryTopics(String categoryId) async {
    final trimmedCategoryId = categoryId.trim();
    if (trimmedCategoryId.isEmpty) return const [];

    final topics = <String>{};

    // 1. Standard Category ID Topic (e.g. category_193)
    final standardTopic = '$_categoryPrefix$trimmedCategoryId';
    if (_isValidFirebaseTopic(standardTopic)) {
      topics.add(standardTopic);
    }

    try {
      final category = await _categoryResolver.resolveById(trimmedCategoryId);
      if (category != null) {
        // 2. URL-encoded Category Name Topic (preserves non-ASCII names safely)
        final encodedCategoryName = Uri.encodeComponent(category.name.trim());
        final encodedTopic = '${encodedCategoryName}_${category.id}';
        if (_isValidFirebaseTopic(encodedTopic)) {
          topics.add(encodedTopic);
        }

        // 3. Raw category name topic (only if it is valid, e.g. English names)
        final rawTopic = '${category.name.trim()}_${category.id}';
        if (_isValidFirebaseTopic(rawTopic)) {
          topics.add(rawTopic);
        }

        // 4. Sanitized category name topic (fallback, replacing non-ASCII with underscores)
        final sanitizedTopic = _sanitizeFirebaseTopic(rawTopic);
        if (sanitizedTopic != null && _isValidFirebaseTopic(sanitizedTopic)) {
          topics.add(sanitizedTopic);
        }
      } else {
        debugPrint(
          '=== FCM TOPICS: CATEGORY NAME NOT FOUND FOR ID $trimmedCategoryId ===',
        );
      }
    } catch (e) {
      debugPrint(
        '=== FCM TOPICS: CATEGORY NAME RESOLVE ERROR ($trimmedCategoryId): $e ===',
      );
    }

    debugPrint(
      '=== FCM TOPICS DEBUG: RESOLVED CATEGORY TOPICS = ${topics.join(', ')} ===',
    );
    return topics.toList();
  }

  String? _sanitizeFirebaseTopic(String topic) {
    final sanitized = topic
        .trim()
        .replaceAll(RegExp(r'\s+'), '_')
        .replaceAll(RegExp(r'[^A-Za-z0-9_\-\.~%]'), '_')
        .replaceAll(RegExp(r'_+'), '_');

    if (sanitized.isEmpty) return null;
    return sanitized;
  }
}
