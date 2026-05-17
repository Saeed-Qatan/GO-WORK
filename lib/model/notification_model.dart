/// Represents a single notification item received from the backend.
class NotificationModel {
  final String id;
  final String title;
  final String body;
  final String? imageUrl;
  final DateTime createdAt;
  final bool isRead;

  const NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    this.imageUrl,
    required this.createdAt,
    required this.isRead,
  });

  /// Creates a [NotificationModel] from a backend JSON response.
  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? 'إشعار جديد',
      body: json['body']?.toString() ?? json['message']?.toString() ?? '',
      imageUrl: json['imageUrl']?.toString(),
      createdAt: _parseDate(
        json['createdAt'] ?? json['date'] ?? json['timestamp'],
      ),
      isRead: json['isRead'] == true || json['read'] == true,
    );
  }

  /// Creates a [NotificationModel] from an incoming FCM push message
  /// (data arrives as key-value string pairs).
  factory NotificationModel.fromFcm({
    required String title,
    required String body,
    String? id,
    String? imageUrl,
  }) {
    return NotificationModel(
      id: id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      body: body,
      imageUrl: imageUrl,
      createdAt: DateTime.now(),
      isRead: false,
    );
  }

  /// Returns a copy of this model with [isRead] set to true.
  NotificationModel copyWithRead() {
    return NotificationModel(
      id: id,
      title: title,
      body: body,
      imageUrl: imageUrl,
      createdAt: createdAt,
      isRead: true,
    );
  }

  static DateTime _parseDate(dynamic value) {
    if (value == null) return DateTime.now();
    try {
      return DateTime.parse(value.toString());
    } catch (_) {
      return DateTime.now();
    }
  }
}
