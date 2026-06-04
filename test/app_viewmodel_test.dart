import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gowork/core/localization/app_localizations.dart';
import 'package:gowork/core/theme/app_theme.dart';
import 'package:gowork/services/language_service.dart';
import 'package:gowork/services/theme_service.dart';
import 'package:gowork/viewmodels/app/app_viewmodel.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    AppColors.useDarkTheme(false);
  });

  test('loadSettings uses saved language and theme', () async {
    SharedPreferences.setMockInitialValues({
      'languageCode': 'en',
      'themeMode': 'dark',
    });

    final viewModel = AppViewModel(
      languageService: LanguageService(),
      themeService: ThemeService(),
    );

    await viewModel.loadSettings();

    expect(viewModel.locale, AppLocalizations.english);
    expect(viewModel.themeMode, ThemeMode.dark);
    expect(viewModel.isDarkMode, isTrue);
  });

  test('changeLanguage saves and exposes the selected locale', () async {
    final viewModel = AppViewModel();
    await viewModel.loadSettings();

    await viewModel.changeLanguage('en');

    final prefs = await SharedPreferences.getInstance();
    expect(viewModel.locale, AppLocalizations.english);
    expect(prefs.getString('languageCode'), 'en');
  });

  test('toggleTheme switches between light and dark and persists it', () async {
    final viewModel = AppViewModel();
    await viewModel.loadSettings();

    await viewModel.toggleTheme();

    final prefs = await SharedPreferences.getInstance();
    expect(viewModel.themeMode, ThemeMode.dark);
    expect(viewModel.isDarkMode, isTrue);
    expect(prefs.getString('themeMode'), 'dark');

    await viewModel.toggleTheme();

    expect(viewModel.themeMode, ThemeMode.light);
    expect(viewModel.isDarkMode, isFalse);
    expect(prefs.getString('themeMode'), 'light');
  });
}
