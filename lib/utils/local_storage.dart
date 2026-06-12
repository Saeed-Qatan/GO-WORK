import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  static final LocalStorage _instance = LocalStorage._internal();
  factory LocalStorage() => _instance;
  LocalStorage._internal();

  static const String _pendingRegistrationEmailKey =
      'pendingRegistrationEmail';
  static const String _pendingRegistrationCategoryIdKey =
      'pendingRegistrationCategoryId';

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

  Future<String> currentUserScope() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId')?.trim();
    return userId == null || userId.isEmpty ? 'anonymous' : userId;
  }

  Future<String> scopedKey(String key) async {
    final scope = await currentUserScope();
    return '${key}_$scope';
  }

  Future<void> saveScopedString(String key, String value) async {
    await saveString(await scopedKey(key), value);
  }

  Future<String?> getScopedString(String key) async {
    return getString(await scopedKey(key));
  }

  Future<void> removeScoped(String key) async {
    await remove(await scopedKey(key));
  }

  Future<void> savePendingRegistrationCategoryId({
    required String email,
    required String categoryId,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();
    final normalizedCategoryId = categoryId.trim();
    if (normalizedEmail.isEmpty || normalizedCategoryId.isEmpty) return;

    await saveString(_pendingRegistrationEmailKey, normalizedEmail);
    await saveString(
      _pendingRegistrationCategoryIdKey,
      normalizedCategoryId,
    );
  }

  Future<String?> consumePendingRegistrationCategoryId(String email) async {
    final normalizedEmail = email.trim().toLowerCase();
    if (normalizedEmail.isEmpty) return null;

    final pendingEmail = await getString(_pendingRegistrationEmailKey);
    final pendingCategoryId =
        await getString(_pendingRegistrationCategoryIdKey);
    final normalizedPendingEmail = pendingEmail?.trim().toLowerCase();
    final normalizedPendingCategoryId = pendingCategoryId?.trim();

    if (normalizedPendingEmail != normalizedEmail ||
        normalizedPendingCategoryId == null ||
        normalizedPendingCategoryId.isEmpty) {
      return null;
    }

    await saveScopedString('categoryId', normalizedPendingCategoryId);
    await remove(_pendingRegistrationEmailKey);
    await remove(_pendingRegistrationCategoryIdKey);
    return normalizedPendingCategoryId;
  }

  Future<void> clearAuth() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('userId');
    await prefs.remove('categoryId');
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    final preservedStrings = <String, String?>{};

    for (final key in prefs.getKeys()) {
      if (key.startsWith('interview_local_statuses_') ||
          key.startsWith('deleted_interview_ids_') ||
          key.startsWith('archived_interviews_') ||
          key.startsWith('withdrawn_applications_') ||
          key.startsWith('optimistic_applications_') ||
          key.startsWith('cached_notifications_') ||
          key.startsWith('categoryId_')) {
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
