part of 'home_model.dart';

enum StatType { interview, review, sent, unknown }

class StatModel {
  final String count;
  final String label;
  final StatType type;

  StatModel({required this.count, required this.label, required this.type});

  factory StatModel.fromJson(Map<String, dynamic> json) {
    final label = json['label']?.toString() ?? '';
    final explicitType = json['type']?.toString();

    var type = _typeFromText(explicitType);
    if (type == StatType.unknown) {
      type = _typeFromText(label);
    }

    return StatModel(
      count: json['count']?.toString() ?? '0',
      label: label,
      type: type,
    );
  }

  static StatType _typeFromText(String? value) {
    final normalized = (value ?? '')
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[\s_\-]+'), '');

    if (normalized.isEmpty) return StatType.unknown;

    if (normalized == 'interview' ||
        normalized == 'interviews' ||
        normalized.contains('interview') ||
        normalized.contains('\u0645\u0642\u0627\u0628\u0644\u0629') ||
        normalized.contains('\u0645\u0642\u0627\u0628\u0644\u0627\u062a') ||
        normalized.contains('Ù…Ù‚Ø§Ø¨Ù„Ø©') ||
        normalized.contains('Ù…Ù‚Ø§Ø¨Ù„Ø§Øª')) {
      return StatType.interview;
    }

    if (normalized == 'review' ||
        normalized == 'pendingreview' ||
        normalized.contains('review') ||
        normalized.contains('pending') ||
        normalized.contains('\u0645\u0631\u0627\u062c\u0639\u0629') ||
        normalized.contains('\u0642\u064a\u062f\u0627\u0644\u0645\u0631\u0627\u062c\u0639\u0629') ||
        normalized.contains('Ù…Ø±Ø§Ø¬Ø¹Ø©')) {
      return StatType.review;
    }

    if (normalized == 'sent' ||
        normalized == 'application' ||
        normalized == 'applications' ||
        normalized.contains('sent') ||
        normalized.contains('application') ||
        normalized.contains('\u0637\u0644\u0628') ||
        normalized.contains('\u0637\u0644\u0628\u0627\u062a') ||
        normalized.contains('\u0645\u0631\u0633\u0644\u0629') ||
        normalized.contains('Ø·Ù„Ø¨') ||
        normalized.contains('Ù…Ø±Ø³Ù„Ø©')) {
      return StatType.sent;
    }

    return StatType.unknown;
  }
}
