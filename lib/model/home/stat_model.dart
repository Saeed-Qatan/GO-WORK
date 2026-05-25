part of 'home_model.dart';

enum StatType { interview, review, sent, unknown }

class StatModel {
  final String count;
  final String label;
  final StatType type;

  StatModel({required this.count, required this.label, required this.type});

  factory StatModel.fromJson(Map<String, dynamic> json) {
    String label = json['label'] ?? '';

    StatType type = StatType.unknown;
    if (label.contains('مقابلة') ||
        label.contains('مقابلات') ||
        label.contains('Interview')) {
      type = StatType.interview;
    } else if (label.contains('مراجعة') || label.contains('Review')) {
      type = StatType.review;
    } else if (label.contains('طلب') ||
        label.contains('مرسلة') ||
        label.contains('Application') ||
        label.contains('Sent')) {
      type = StatType.sent;
    }

    return StatModel(
      count: json['count']?.toString() ?? '0',
      label: label,
      type: type,
    );
  }
}
