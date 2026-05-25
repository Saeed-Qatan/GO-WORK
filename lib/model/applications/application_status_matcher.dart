part of 'application_model.dart';

class ApplicationStatusMatcher {
  static String normalize(String? value) {
    return (value ?? '').trim().toLowerCase().replaceAll(
      RegExp(r'[\s_\-]+'),
      '',
    );
  }
}
