import '../utils/timezone_utils.dart';

enum NotificationType {
  general,
  jobCreated,
  applicationAccepted,
  applicationRejected,
  interviewScheduled,
  unknown,
}

enum NotificationDeliveryType { topic, user, unknown }

/// Represents a single notification item received from the backend or FCM.
class NotificationModel {
  final int id;
  final int? notificationId;
  final String title;
  final String body;
  final NotificationType type;
  final String typeRaw;
  final NotificationDeliveryType deliveryType;
  final String? deliveryTypeRaw;
  final DateTime createdAt;
  final bool isRead;
  final String? actionUrl;
  final String? imageUrl;

  const NotificationModel({
    required this.id,
    this.notificationId,
    required this.title,
    required this.body,
    required this.type,
    required this.typeRaw,
    required this.deliveryType,
    this.deliveryTypeRaw,
    required this.createdAt,
    required this.isRead,
    this.actionUrl,
    this.imageUrl,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    final rawType = json['type']?.toString() ?? 'General';
    final rawDeliveryType = json['deliveryType']?.toString();

    return NotificationModel(
      id: _parseInt(json['id']),
      notificationId: _parseNullableInt(json['notificationId']),
      title: json['title']?.toString() ?? 'إشعار جديد',
      body: json['body']?.toString() ?? json['message']?.toString() ?? '',
      type: _parseType(rawType),
      typeRaw: rawType,
      deliveryType: _parseDeliveryType(rawDeliveryType),
      deliveryTypeRaw: rawDeliveryType,
      createdAt: _parseDate(
        json['createdAt'] ?? json['date'] ?? json['timestamp'],
      ),
      isRead: _parseBool(json['isRead'] ?? json['read']),
      actionUrl: _emptyToNull(json['actionUrl']?.toString()),
      imageUrl: _emptyToNull(json['imageUrl']?.toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'notificationId': notificationId,
      'title': title,
      'body': body,
      'type': typeRaw,
      'deliveryType': deliveryTypeRaw,
      'createdAt': createdAt.toUtc().toIso8601String(),
      'isRead': isRead,
      'actionUrl': actionUrl,
      'imageUrl': imageUrl,
    };
  }

  factory NotificationModel.fromFcm({
    required String title,
    required String body,
    int? id,
    int? notificationId,
    String? type,
    String? actionUrl,
    String? imageUrl,
  }) {
    final rawType = type ?? 'General';
    return NotificationModel(
      id: id ?? DateTime.now().millisecondsSinceEpoch,
      notificationId: notificationId,
      title: title,
      body: body,
      type: _parseType(rawType),
      typeRaw: rawType,
      deliveryType: NotificationDeliveryType.unknown,
      createdAt: DateTime.now(),
      isRead: false,
      actionUrl: _emptyToNull(actionUrl),
      imageUrl: _emptyToNull(imageUrl),
    );
  }

  NotificationModel copyWith({
    int? id,
    int? notificationId,
    String? title,
    String? body,
    NotificationType? type,
    String? typeRaw,
    NotificationDeliveryType? deliveryType,
    String? deliveryTypeRaw,
    DateTime? createdAt,
    bool? isRead,
    String? actionUrl,
    String? imageUrl,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      notificationId: notificationId ?? this.notificationId,
      title: title ?? this.title,
      body: body ?? this.body,
      type: type ?? this.type,
      typeRaw: typeRaw ?? this.typeRaw,
      deliveryType: deliveryType ?? this.deliveryType,
      deliveryTypeRaw: deliveryTypeRaw ?? this.deliveryTypeRaw,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
      actionUrl: actionUrl ?? this.actionUrl,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

  NotificationModel copyWithRead() => copyWith(isRead: true);

  String get displayTitle {
    if (_isDefaultJobTitle(title)) {
      return 'فرصة عمل جديدة!';
    }
    if (title.trim().toLowerCase() == 'new notification') {
      return 'إشعار جديد';
    }
    return title;
  }

  String get displayBody {
    final translated = _translateJobBody(body);
    if (translated != null) return translated;

    if (_isDefaultJobBody(body)) {
      return 'اضغط لعرض تفاصيل الوظيفة والتقديم.';
    }
    return body;
  }

  static String? _translateJobBody(String value) {
    final RegExp regex = RegExp(
      r'a new (.*?) position has just opened up[\.\s]*tap to view details and apply!?',
      caseSensitive: false,
    );
    final match = regex.firstMatch(value.trim());
    if (match != null && match.groupCount >= 1) {
      final jobName = match.group(1);
      return 'شواغر جديدة لوظيفة $jobName متاحة الآن. اضغط لعرض التفاصيل والتقديم!';
    }
    return null;
  }

  static bool _isDefaultJobTitle(String value) {
    switch (value.trim().toLowerCase()) {
      case 'new job opportunity!':
      case 'new job opportunity':
      case 'new job':
      case 'job created':
      case 'jobcreated':
      case 'إشعار جديد':
        return true;
      default:
        return false;
    }
  }

  static bool _isDefaultJobBody(String value) {
    switch (value.trim().toLowerCase()) {
      case 'tap to view details and apply!':
      case 'tap to view details and apply':
      case 'view details and apply':
        return true;
      default:
        return false;
    }
  }

  static NotificationType _parseType(String? value) {
    switch (value?.trim().toLowerCase()) {
      case 'general':
        return NotificationType.general;
      case 'jobcreated':
        return NotificationType.jobCreated;
      case 'applicationaccepted':
        return NotificationType.applicationAccepted;
      case 'applicationrejected':
        return NotificationType.applicationRejected;
      case 'interviewscheduled':
        return NotificationType.interviewScheduled;
      default:
        return NotificationType.unknown;
    }
  }

  static NotificationDeliveryType _parseDeliveryType(String? value) {
    switch (value?.trim().toLowerCase()) {
      case 'topic':
        return NotificationDeliveryType.topic;
      case 'user':
        return NotificationDeliveryType.user;
      default:
        return NotificationDeliveryType.unknown;
    }
  }

  static int _parseInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ??
        DateTime.now().millisecondsSinceEpoch;
  }

  static int? _parseNullableInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
  }

  static DateTime _parseDate(dynamic value) {
    if (value == null) return DateTime.now();
    return TimezoneUtils.tryParseUtcToLocal(value) ?? DateTime.now();
  }

  static bool _parseBool(dynamic value) {
    if (value is bool) return value;
    if (value is num) return value != 0;

    switch (value?.toString().trim().toLowerCase()) {
      case 'true':
      case '1':
      case 'yes':
      case 'y':
        return true;
      default:
        return false;
    }
  }

  static String? _emptyToNull(String? value) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) return null;
    return trimmed;
  }
}

class NotificationsPage {
  final List<NotificationModel> items;
  final int currentPage;
  final int pageSize;
  final int totalCount;
  final int totalPages;

  const NotificationsPage({
    required this.items,
    required this.currentPage,
    required this.pageSize,
    required this.totalCount,
    required this.totalPages,
  });

  bool get hasMore => currentPage < totalPages;

  factory NotificationsPage.fromJson(Map<String, dynamic> json) {
    final data = json['data'] is Map<String, dynamic>
        ? json['data'] as Map<String, dynamic>
        : json;
    final rawItems = data['items'] is List
        ? data['items'] as List
        : <dynamic>[];

    return NotificationsPage(
      items: rawItems
          .whereType<Map<String, dynamic>>()
          .map(NotificationModel.fromJson)
          .toList(),
      currentPage: _readInt(data['currentPage'], fallback: 1),
      pageSize: _readInt(data['pageSize'], fallback: rawItems.length),
      totalCount: _readInt(data['totalCount'], fallback: rawItems.length),
      totalPages: _readInt(data['totalPages'], fallback: 1),
    );
  }

  static int _readInt(dynamic value, {required int fallback}) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? fallback;
  }
}
