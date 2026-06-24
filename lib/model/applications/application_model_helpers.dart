part of 'application_model.dart';

Map<String, dynamic>? _asMap(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return Map<String, dynamic>.from(value);
  return null;
}

String _readString(dynamic value) {
  if (value is Map || value is Iterable) return '';
  return value?.toString().trim() ?? '';
}

String? _nullableString(dynamic value) {
  final text = _readString(value);
  return text.isEmpty ? null : text;
}

String _firstNonEmpty(List<dynamic> values) {
  return _firstNonEmptyOrNull(values) ?? '';
}

String? _firstNonEmptyOrNull(List<dynamic> values) {
  for (final value in values) {
    final text = _readString(value);
    if (text.isNotEmpty) return text;
  }
  return null;
}

bool? _readBool(dynamic value) {
  if (value is bool) return value;
  final text = _readString(value).toLowerCase();
  if (text == 'true' || text == '1') return true;
  if (text == 'false' || text == '0') return false;
  return null;
}

bool _hasArabic(String value) {
  return RegExp(r'[\u0600-\u06FF]').hasMatch(value);
}
