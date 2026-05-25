class StatusTranslator {
  static const String genericArabicError =
      'حدث خطأ غير متوقع، يرجى المحاولة مرة أخرى';

  static const Map<String, String> _jobTypeLabels = {
    'fulltime': 'دوام كامل',
    'full_time': 'دوام كامل',
    'full-time': 'دوام كامل',
    'parttime': 'دوام جزئي',
    'part_time': 'دوام جزئي',
    'part-time': 'دوام جزئي',
    'contract': 'عقد',
    'temporary': 'مؤقت',
    'internship': 'تدريب',
    'freelance': 'عمل حر',
  };

  static const Map<String, String> _workModeLabels = {
    'remote': 'عن بعد',
    'onsite': 'حضوري',
    'on_site': 'حضوري',
    'on-site': 'حضوري',
    'hybrid': 'هجين',
    'inperson': 'حضوري',
    'offline': 'حضوري',
  };

  static const Map<String, String> _currencyLabels = {
    'sar': 'ريال سعودي',
    'saudi riyal': 'ريال سعودي',
    'riyal': 'ريال',
    'yer': 'ريال يمني',
    'yemeni rial': 'ريال يمني',
    'usd': 'دولار أمريكي',
    'dollar': 'دولار',
  };

  static String normalize(String? value) {
    return (value ?? '').trim().toLowerCase().replaceAll(
      RegExp(r'[\s_\-]+'),
      '',
    );
  }

  static bool hasArabic(String? value) {
    return value != null && RegExp(r'[\u0600-\u06FF]').hasMatch(value);
  }

  static bool hasLatin(String? value) {
    return value != null && RegExp(r'[A-Za-z]').hasMatch(value);
  }

  static bool isEnglishOnly(String? value) {
    final text = value?.trim();
    return text != null &&
        text.isNotEmpty &&
        hasLatin(text) &&
        !hasArabic(text);
  }

  static String jobTypeLabel(String? value) {
    return _translateSystemValue(value, _jobTypeLabels);
  }

  static String workModeLabel(String? value) {
    return _translateSystemValue(value, _workModeLabels);
  }

  static String currencyLabel(String? value) {
    return _translateSystemValue(value, _currencyLabels);
  }

  static String backendMessage(
    String? message, {
    String fallbackMessage = genericArabicError,
  }) {
    final text = message?.trim();
    if (text == null || text.isEmpty) return fallbackMessage;

    if (hasArabic(text)) return text;

    final lower = text.toLowerCase();

    if (lower.contains('password changed') ||
        lower.contains('password has been changed')) {
      return 'تم تغيير كلمة المرور بنجاح';
    }
    if (lower.contains('feedback') && lower.contains('sent')) {
      return 'تم إرسال الرسالة بنجاح';
    }
    if (lower.contains('interview') && lower.contains('confirmed')) {
      return 'تم تأكيد حضور المقابلة';
    }
    if (lower.contains('interview') &&
        (lower.contains('cancelled') || lower.contains('declined'))) {
      return 'تم الاعتذار عن حضور المقابلة';
    }
    if (lower.contains('application') && lower.contains('withdraw')) {
      return 'تم سحب الطلب بنجاح';
    }
    if (lower.contains('successfully') || lower == 'success') {
      return 'تمت العملية بنجاح';
    }

    return isEnglishOnly(text) ? fallbackMessage : text;
  }

  static String _translateSystemValue(
    String? value,
    Map<String, String> labels,
  ) {
    final text = value?.trim();
    if (text == null || text.isEmpty) return '';
    if (hasArabic(text)) return text;

    final normalized = normalize(text);
    if (labels.containsKey(normalized)) {
      return labels[normalized]!;
    }

    for (final entry in labels.entries) {
      if (normalized.contains(normalize(entry.key))) {
        return entry.value;
      }
    }

    return text;
  }
}
