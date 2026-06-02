import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  static final LocalStorage _instance = LocalStorage._internal();
  factory LocalStorage() => _instance;
  LocalStorage._internal();

  Future<void> saveString(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

  Future<String?> getString(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  Future<void> saveBool(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  Future<bool?> getBool(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(key);
  }

  Future<void> saveInt(String key, int value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(key, value);
  }

  Future<int?> getInt(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(key);
  }

  Future<void> remove(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
  }

  Future<void> clearAuth() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('userId');
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    final preservedStrings = <String, String?>{
      'withdrawn_applications': prefs.getString('withdrawn_applications'),
    };

    for (final key in prefs.getKeys()) {
      if (key.startsWith('interview_local_statuses_') ||
          key.startsWith('deleted_interview_ids_') ||
          key.startsWith('archived_interviews_')) {
        preservedStrings[key] = prefs.getString(key);
      }
    }

    await prefs.clear();
    for (final entry in preservedStrings.entries) {
      if (entry.value != null) {
        await prefs.setString(entry.key, entry.value!);
      }
    }
  }
}
