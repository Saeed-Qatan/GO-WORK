import '../model/application_model.dart';

class StatusTranslator {
  static const Map<String, ApplicationStatus> _apiToEnumMap = {
    '1': ApplicationStatus.sent,
    'sent': ApplicationStatus.sent,
    '2': ApplicationStatus.inReview,
    'pendingreview': ApplicationStatus.inReview,
    'review': ApplicationStatus.inReview,
    'inreview': ApplicationStatus.inReview,
    '3': ApplicationStatus.accepted,
    'accepted': ApplicationStatus.accepted,
    'accept': ApplicationStatus.accepted,
    '4': ApplicationStatus.rejected,
    'rejected': ApplicationStatus.rejected,
    'reject': ApplicationStatus.rejected,
    '5': ApplicationStatus.withdrawn,
    'withdrawn': ApplicationStatus.withdrawn,
    'withdraw': ApplicationStatus.withdrawn,
  };

  /// Retrieves the corresponding ApplicationStatus enum from an API status string.
  static ApplicationStatus getEnum(String? apiStatus) {
    if (apiStatus == null) return ApplicationStatus.sent;
    final normalized = apiStatus.toLowerCase().replaceAll(' ', '');
    
    // Direct lookup
    if (_apiToEnumMap.containsKey(normalized)) {
      return _apiToEnumMap[normalized]!;
    }

    // Contains lookup as a fallback
    for (var entry in _apiToEnumMap.entries) {
      if (normalized.contains(entry.key)) {
        return entry.value;
      }
    }

    return ApplicationStatus.sent;
  }
}

extension ApplicationStatusExt on ApplicationStatus {
  String get arabicLabel {
    switch (this) {
      case ApplicationStatus.sent:
        return 'تم التقديم';
      case ApplicationStatus.inReview:
        return 'قيد المراجعة';
      case ApplicationStatus.accepted:
        return 'تم القبول';
      case ApplicationStatus.rejected:
        return 'مرفوض';
      case ApplicationStatus.withdrawn:
        return 'تم السحب';
    }
  }

  String get englishApiValue {
    switch (this) {
      case ApplicationStatus.sent:
        return 'Sent';
      case ApplicationStatus.inReview:
        return 'PendingReview';
      case ApplicationStatus.accepted:
        return 'Accepted';
      case ApplicationStatus.rejected:
        return 'Rejected';
      case ApplicationStatus.withdrawn:
        return 'Withdrawn';
    }
  }

  int get colorHex {
    switch (this) {
      case ApplicationStatus.inReview:
        return 0xFFB79C12; // Goldish
      case ApplicationStatus.accepted:
        return 0xFF2E7D32; // Green
      case ApplicationStatus.rejected:
        return 0xFFC62828; // Red
      case ApplicationStatus.sent:
        return 0xFF1565C0; // Blue
      case ApplicationStatus.withdrawn:
        return 0xFF757575; // Grey
    }
  }

  int get bgColorHex {
    switch (this) {
      case ApplicationStatus.inReview:
        return 0xFFFFF9C4; // Light Yellow
      case ApplicationStatus.accepted:
        return 0xFFE8F5E9; // Light Green
      case ApplicationStatus.rejected:
        return 0xFFFFEBEE; // Light Red
      case ApplicationStatus.sent:
        return 0xFFE3F2FD; // Light Blue
      case ApplicationStatus.withdrawn:
        return 0xFFEEEEEE; // Light Grey
    }
  }

  int? get iconCodePoint {
    switch (this) {
      case ApplicationStatus.inReview:
        return 0xe03a; // Icons.access_time
      case ApplicationStatus.accepted:
        return 0xe156; // Icons.check
      case ApplicationStatus.rejected:
        return 0xe14c; // Icons.close
      case ApplicationStatus.sent:
        return null;
      case ApplicationStatus.withdrawn:
        return null;
    }
  }
}
