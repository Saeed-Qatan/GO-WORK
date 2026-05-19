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
