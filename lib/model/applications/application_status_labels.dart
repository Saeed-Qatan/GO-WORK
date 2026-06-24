part of 'application_model.dart';

class ApplicationStatusLabels {
  static const Map<String, String> _arabicLabels = {
    '0': 'تم التقديم',

    'interviewed': 'تم التقديم',
    '1': 'قيد المراجعة',

    'pendingreview': 'قيد المراجعة',

    '2': 'تم القبول',
    'accepted': 'تم القبول',

    '3': 'مرفوض',
    'rejected': 'مرفوض',

    '4': 'تم السحب',
    'withdrawn': 'تم السحب',

    '5': 'تم التوظيف',
    'hired': 'تم التوظيف',
    'hire': 'تم التوظيف',

    '6': 'لم يحضر المقابلة',
    'missinginterview': 'لم يحضر المقابلة',
    'missinterview': 'لم يحضر المقابلة',
    'missedinterview': 'لم يحضر المقابلة',
  };

  static String arabicLabelFor(Iterable<dynamic> values) {
    String firstReadableValue = '';

    for (final value in values) {
      final text = _readString(value);
      if (text.isEmpty) continue;
      firstReadableValue = firstReadableValue.isEmpty
          ? text
          : firstReadableValue;
      if (_hasArabic(text)) return text;

      final normalized = ApplicationStatusMatcher.normalize(text);
      final exact = _arabicLabels[normalized];
      if (exact != null) return exact;

      for (final entry in _arabicLabels.entries) {
        if (int.tryParse(entry.key) != null) continue;
        if (normalized.contains(entry.key)) return entry.value;
      }
    }

    return firstReadableValue;
  }

  static bool isWithdrawn(Iterable<dynamic> values) {
    for (final value in values) {
      final normalized = ApplicationStatusMatcher.normalize(_readString(value));
      if (normalized.isEmpty) continue;
      if (normalized == '4' ||
          normalized.contains('withdraw') ||
          normalized.contains('cancel') ||
          normalized.contains('سحب')) {
        return true;
      }
    }

    return false;
  }
}
