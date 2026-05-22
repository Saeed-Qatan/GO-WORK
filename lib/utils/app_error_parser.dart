import 'package:dio/dio.dart';
import 'status_translator.dart';

class AppApiException implements Exception {
  final String message;
  final int? statusCode;
  final Object? data;

  const AppApiException(this.message, {this.statusCode, this.data});

  @override
  String toString() => message;
}

class AppErrorParser {
  AppErrorParser._();

  static const String _defaultFallback =
      'حدث خطأ غير متوقع، يرجى المحاولة مرة أخرى';

  static String parse(
    Object error, {
    String fallbackMessage = _defaultFallback,
  }) {
    if (error is AppApiException) {
      return _cleanMessage(error.message, fallbackMessage: fallbackMessage);
    }

    if (error is DioException) {
      return _parseDio(error, fallbackMessage: fallbackMessage);
    }

    return _parseGeneric(error.toString(), fallbackMessage: fallbackMessage);
  }

  static String parseResponseData(
    Object? data, {
    int? statusCode,
    String fallbackMessage = _defaultFallback,
  }) {
    final extracted = _extractMessage(data);
    if (extracted != null) {
      return _cleanMessage(extracted, fallbackMessage: fallbackMessage);
    }

    if (statusCode != null) {
      return _messageForStatus(statusCode);
    }

    return fallbackMessage;
  }

  static String _parseDio(
    DioException error, {
    required String fallbackMessage,
  }) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'انتهت مهلة الاتصال، يرجى المحاولة لاحقاً';

      case DioExceptionType.connectionError:
        return 'لا يوجد اتصال بالإنترنت، تحقق من الشبكة وأعد المحاولة';

      case DioExceptionType.badResponse:
        return parseResponseData(
          error.response?.data,
          statusCode: error.response?.statusCode,
          fallbackMessage: fallbackMessage,
        );

      case DioExceptionType.cancel:
        return 'تم إلغاء الطلب';

      case DioExceptionType.badCertificate:
        return 'تعذر التحقق من أمان الاتصال، يرجى المحاولة لاحقاً';

      case DioExceptionType.unknown:
        final rawError = error.error?.toString();
        if (rawError != null && rawError.trim().isNotEmpty) {
          return _parseGeneric(rawError, fallbackMessage: fallbackMessage);
        }
        return fallbackMessage;
    }
  }

  static String? _extractMessage(Object? data) {
    if (data == null) return null;

    if (data is String) {
      final cleaned = data.trim();
      return cleaned.isEmpty ? null : cleaned;
    }

    if (data is Iterable) {
      return _joinMessages(data);
    }

    if (data is Map) {
      final errors = _extractMessage(data['errors'] ?? data['Errors']);
      if (errors != null) return errors;

      for (final key in const [
        'message',
        'Message',
        'error',
        'Error',
        'title',
        'Title',
      ]) {
        final value = _extractMessage(data[key]);
        if (value != null) return value;
      }

      final nestedData = data['data'] ?? data['Data'];
      if (nestedData is Map || nestedData is Iterable || nestedData is String) {
        final nestedMessage = _extractMessage(nestedData);
        if (nestedMessage != null) return nestedMessage;
      }

      return _joinMessages(data.values);
    }

    return null;
  }

  static String? _joinMessages(Iterable values) {
    final messages =
        values
            .map(_extractMessage)
            .whereType<String>()
            .map((message) => message.trim())
            .where((message) => message.isNotEmpty)
            .toList();

    if (messages.isEmpty) return null;
    return messages.toSet().join('\n');
  }

  static String _parseGeneric(String raw, {required String fallbackMessage}) {
    var cleaned =
        raw
            .replaceFirst(RegExp(r'^Exception:\s*'), '')
            .replaceFirst(RegExp(r'^FormatException:\s*'), '')
            .trim();

    final statusMatch = RegExp(r'^Error\s+(\d{3})\s*:').firstMatch(cleaned);
    if (statusMatch != null) {
      final statusCode = int.tryParse(statusMatch.group(1)!);
      final message = _extractMessage(cleaned.substring(statusMatch.end));
      if (message != null && !_looksLikeRawPayload(message)) {
        return _cleanMessage(message, fallbackMessage: fallbackMessage);
      }
      if (statusCode != null) return _messageForStatus(statusCode);
    }

    cleaned = _translateKnownBackendMessage(cleaned);

    if (cleaned.isEmpty ||
        _looksLikeTechnicalError(cleaned) ||
        StatusTranslator.isEnglishOnly(cleaned)) {
      return fallbackMessage;
    }

    return cleaned;
  }

  static String _cleanMessage(
    String message, {
    required String fallbackMessage,
  }) {
    final cleaned = _translateKnownBackendMessage(message.trim());
    if (cleaned.isEmpty ||
        _looksLikeTechnicalError(cleaned) ||
        StatusTranslator.isEnglishOnly(cleaned)) {
      return fallbackMessage;
    }
    return cleaned;
  }

  static String _translateKnownBackendMessage(String message) {
    final lower = message.toLowerCase();

    if (lower.contains('job is closed or expired')) {
      return 'الوظيفة مغلقة أو منتهية الصلاحية.';
    }

    if (lower.contains('invalid credentials') ||
        lower.contains('invalid username') ||
        lower.contains('invalid password') ||
        lower.contains('wrong password')) {
      return 'بيانات الدخول غير صحيحة، يرجى التحقق والمحاولة مرة أخرى';
    }

    if (lower.contains('unauthorized') || lower.contains('not authorized')) {
      return 'انتهت صلاحية الجلسة، يرجى تسجيل الدخول مجدداً';
    }

    if (lower.contains('user not found') ||
        lower.contains('account not found')) {
      return 'لم يتم العثور على الحساب';
    }

    if (lower.contains('current password') &&
        (lower.contains('incorrect') || lower.contains('invalid'))) {
      return 'كلمة المرور الحالية غير صحيحة';
    }

    if (lower.contains('already applied') ||
        lower.contains('already submitted')) {
      return 'لقد قمت بالتقديم على هذه الوظيفة مسبقاً';
    }

    if (lower.contains('email') &&
        (lower.contains('already') ||
            lower.contains('exists') ||
            lower.contains('taken') ||
            lower.contains('duplicate'))) {
      return 'البريد الإلكتروني مسجل مسبقاً. يرجى استخدام بريد آخر.';
    }

    if ((lower.contains('phone') || lower.contains('mobile')) &&
        (lower.contains('already') ||
            lower.contains('exists') ||
            lower.contains('taken') ||
            lower.contains('duplicate'))) {
      return 'رقم الهاتف مسجل مسبقاً. يرجى استخدام رقم آخر.';
    }

    if (lower.contains('failed to apply')) {
      return 'تعذر التقديم على الوظيفة، يرجى المحاولة مرة أخرى';
    }

    if (lower.contains('password reset failed')) {
      return 'تعذر إعادة تعيين كلمة المرور، يرجى المحاولة مرة أخرى';
    }

    if (lower.contains('verification failed')) {
      return 'تعذر التحقق من الكود، يرجى المحاولة مرة أخرى';
    }

    if (lower.contains('resend failed')) {
      return 'تعذر إعادة إرسال الكود، يرجى المحاولة مرة أخرى';
    }

    if (lower.contains('failed to send reset link')) {
      return 'تعذر إرسال كود التحقق، يرجى المحاولة مرة أخرى';
    }

    final translated = StatusTranslator.backendMessage(message, fallbackMessage: '');
    if (translated.isNotEmpty && translated != message) {
      return translated;
    }

    return message;
  }

  static bool _looksLikeTechnicalError(String text) {
    return text.startsWith('SocketException') ||
        text.startsWith('HandshakeException') ||
        text.startsWith('HttpException') ||
        text.startsWith('PathNotFoundException') ||
        text.startsWith('FileSystemException') ||
        text.startsWith('DioException') ||
        text.contains('#0 ') ||
        text.contains('dart:') ||
        text.contains('package:') ||
        _looksLikeRawPayload(text);
  }

  static bool _looksLikeRawPayload(String text) {
    final trimmed = text.trim();
    return (trimmed.startsWith('{') && trimmed.endsWith('}')) ||
        (trimmed.startsWith('[') && trimmed.endsWith(']')) ||
        trimmed.contains('Instance of ');
  }

  static String _messageForStatus(int code) {
    switch (code) {
      case 400:
        return 'البيانات المرسلة غير صحيحة';
      case 401:
        return 'انتهت صلاحية الجلسة، يرجى تسجيل الدخول مجدداً';
      case 403:
        return 'ليس لديك صلاحية للقيام بهذا الإجراء';
      case 404:
        return 'البيانات المطلوبة غير موجودة';
      case 409:
        return 'البيانات المدخلة مكررة';
      case 422:
        return 'بيانات غير صالحة، يرجى مراجعة المعلومات المدخلة';
      case 429:
        return 'الطلبات كثيرة جداً، يرجى الانتظار قليلاً';
      case 500:
      case 502:
      case 503:
        return 'يوجد خطأ في الخادم، يرجى المحاولة لاحقاً';
      default:
        return _defaultFallback;
    }
  }
}
