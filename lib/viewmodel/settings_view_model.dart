import 'package:flutter/material.dart';

class SettingsViewModel extends ChangeNotifier {
  bool _notificationsEnabled = true;
  String _currentLanguage = 'العربية';

  bool get notificationsEnabled => _notificationsEnabled;
  String get currentLanguage => _currentLanguage;

  void toggleNotifications(bool value) {
    _notificationsEnabled = value;
    // Here you would typically also save this to SharedPreferences
    notifyListeners();
  }

  void changeLanguage(String language) {
    _currentLanguage = language;
    // Here you would typically save this to SharedPreferences and update locale
    notifyListeners();
  }
}
