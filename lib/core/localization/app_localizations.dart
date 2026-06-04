import 'package:flutter/material.dart';

class AppLocalizations {
  AppLocalizations._();

  static const Locale arabic = Locale('ar', 'AE');
  static const Locale english = Locale('en', 'US');

  static const List<Locale> supportedLocales = [english, arabic];
  static const Locale fallbackLocale = arabic;
  static const Locale startLocale = arabic;
  static const String translationsPath = 'lib/core/localization';

  static Locale localeFromLanguageCode(String? languageCode) {
    switch (languageCode) {
      case 'en':
        return english;
      case 'ar':
      default:
        return arabic;
    }
  }

  static String languageCodeFromLocale(Locale locale) {
    return locale.languageCode == english.languageCode ? 'en' : 'ar';
  }

  static bool isSupported(Locale locale) {
    return supportedLocales.any(
      (supported) => supported.languageCode == locale.languageCode,
    );
  }
}
