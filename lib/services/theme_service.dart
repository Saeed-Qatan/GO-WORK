import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeService {
  static const String _themeKey = 'themeMode';
  static const String _light = 'light';
  static const String _dark = 'dark';
  static const String _system = 'system';

  Future<void> saveTheme(ThemeMode themeMode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, _encode(themeMode));
  }

  Future<ThemeMode?> getTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(_themeKey);
    if (value == null) return null;
    return _decode(value);
  }

  String _encode(ThemeMode themeMode) {
    switch (themeMode) {
      case ThemeMode.light:
        return _light;
      case ThemeMode.dark:
        return _dark;
      case ThemeMode.system:
        return _system;
    }
  }

  ThemeMode _decode(String value) {
    switch (value) {
      case _dark:
        return ThemeMode.dark;
      case _system:
        return ThemeMode.system;
      case _light:
      default:
        return ThemeMode.light;
    }
  }
}
