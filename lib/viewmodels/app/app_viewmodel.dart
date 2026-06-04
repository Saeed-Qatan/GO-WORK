import 'package:flutter/material.dart';

import '../../core/localization/app_localizations.dart';
import '../../core/theme/app_theme.dart';
import '../../services/language_service.dart';
import '../../services/theme_service.dart';

class AppViewModel extends ChangeNotifier {
  final LanguageService _languageService;
  final ThemeService _themeService;

  Locale _locale = AppLocalizations.startLocale;
  ThemeMode _themeMode = ThemeMode.light;
  bool _isLoading = true;

  AppViewModel({LanguageService? languageService, ThemeService? themeService})
    : _languageService = languageService ?? LanguageService(),
      _themeService = themeService ?? ThemeService();

  Locale get locale => _locale;
  ThemeMode get themeMode => _themeMode;
  bool get isLoading => _isLoading;
  bool get isDarkMode => _themeMode == ThemeMode.dark;
  String get currentLanguageCode =>
      AppLocalizations.languageCodeFromLocale(_locale);

  Future<void> loadSettings() async {
    final savedLanguage = await _languageService.getLanguage();
    final savedTheme = await _themeService.getTheme();

    _locale = AppLocalizations.localeFromLanguageCode(savedLanguage);
    _themeMode = savedTheme ?? ThemeMode.light;
    AppColors.useDarkTheme(isDarkMode);
    _isLoading = false;
    notifyListeners();
  }

  Future<void> changeLanguage(String languageCode) async {
    final nextLocale = AppLocalizations.localeFromLanguageCode(languageCode);
    if (_locale == nextLocale) return;

    _locale = nextLocale;
    await _languageService.saveLanguage(
      AppLocalizations.languageCodeFromLocale(nextLocale),
    );
    notifyListeners();
  }

  Future<void> changeTheme(ThemeMode themeMode) async {
    if (_themeMode == themeMode) return;

    _themeMode = themeMode;
    AppColors.useDarkTheme(isDarkMode);
    await _themeService.saveTheme(themeMode);
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    await changeTheme(isDarkMode ? ThemeMode.light : ThemeMode.dark);
  }
}
