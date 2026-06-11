class TimezoneUtils {
  TimezoneUtils._();

  static Map<String, String> requestHeaders({DateTime? now}) {
    final current = now ?? DateTime.now();
    return {
      'Time-Zone': current.timeZoneName,
      'X-Timezone-Offset': formatOffset(current.timeZoneOffset),
    };
  }

  static String get currentTimeZoneName => DateTime.now().timeZoneName;

  static String get currentTimezoneOffset =>
      formatOffset(DateTime.now().timeZoneOffset);

  static String formatOffset(Duration offset) {
    final sign = offset.isNegative ? '-' : '+';
    final totalMinutes = offset.inMinutes.abs();
    final hours = (totalMinutes ~/ 60).toString().padLeft(2, '0');
    final minutes = (totalMinutes % 60).toString().padLeft(2, '0');
    return '$sign$hours:$minutes';
  }

  static DateTime? tryParseUtcToLocal(dynamic value) {
    final text = value?.toString().trim();
    if (text == null || text.isEmpty) return null;

    final parsed = DateTime.tryParse(text);
    if (parsed == null) return null;

    if (_hasExplicitTimezone(text) || !_containsTime(text)) {
      return parsed.toLocal();
    }

    return DateTime.utc(
      parsed.year,
      parsed.month,
      parsed.day,
      parsed.hour,
      parsed.minute,
      parsed.second,
      parsed.millisecond,
      parsed.microsecond,
    ).toLocal();
  }

  static DateTime parseUtcToLocal(dynamic value, {DateTime? fallback}) {
    return tryParseUtcToLocal(value) ?? fallback ?? DateTime.now();
  }

  static bool _containsTime(String value) {
    return value.contains('T') || RegExp(r'\d\s+\d{1,2}:').hasMatch(value);
  }

  static bool _hasExplicitTimezone(String value) {
    return value.endsWith('Z') ||
        value.endsWith('z') ||
        RegExp(r'[+-]\d{2}:?\d{2}$').hasMatch(value);
  }
}
