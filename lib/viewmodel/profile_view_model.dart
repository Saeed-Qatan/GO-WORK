import 'dart:io';
import 'package:flutter/material.dart';
import '../model/profile_model.dart';
import '../repository/profile_repository.dart';
import '../repository/notifications_repository.dart';
import '../services/notification_topic_service.dart';
import '../utils/local_storage.dart';
import '../utils/app_error_parser.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'session_resettable.dart';

class ProfileViewModel extends ChangeNotifier implements SessionResettable {
  final ProfileRepository _repository = ProfileRepository();
  final NotificationsRepository _notificationsRepository =
      NotificationsRepository();
  final LocalStorage _storage = LocalStorage();
  final NotificationTopicService? _notificationTopicService;
  int _sessionVersion = 0;
  ProfileModel? _profile;
  ProfileModel? get profile => _profile;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  ProfileViewModel({NotificationTopicService? notificationTopicService})
    : _notificationTopicService = notificationTopicService;

  Future<void> fetchProfile({
    String? previousCategoryId,
    String? preferredCategoryId,
  }) async {
    final requestVersion = _sessionVersion;
    final showBlockingLoading = _profile == null;
    if (showBlockingLoading) {
      _isLoading = true;
    }
    _errorMessage = null;
    notifyListeners();

    try {
      final oldCategoryId = previousCategoryId ?? _profile?.categoryId;
      final profile = await _repository.getUserProfile();
      if (requestVersion != _sessionVersion) return;
      _profile = profile;
      final requestedCategoryId = preferredCategoryId?.trim();
      if (_profile != null &&
          requestedCategoryId != null &&
          requestedCategoryId.isNotEmpty) {
        _profile = _profile!.copyWith(categoryId: requestedCategoryId);
        await _storage.saveScopedString('categoryId', requestedCategoryId);
      }
      debugPrint(
        '=== PROFILE DEBUG: CATEGORY ID = ${_profile?.categoryId.isNotEmpty == true ? _profile!.categoryId : 'EMPTY'} ===',
      );
      if (requestVersion != _sessionVersion) return;
      await _notificationTopicService?.syncUserTopics(
        previousCategoryId: oldCategoryId,
        categoryId: _profile?.categoryId,
      );
    } catch (e) {
      if (requestVersion != _sessionVersion) return;
      debugPrint('Error fetching profile: $e');
      _errorMessage = AppErrorParser.parse(e);
    } finally {
      if (requestVersion == _sessionVersion) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  void seedProfile(ProfileModel profile, {bool notify = true}) {
    _profile = profile;
    _isLoading = false;
    _errorMessage = null;
    if (notify) notifyListeners();
  }

  /// PATCH /Account/Candidate/UpdateProfile - form-data with all fields + files.
  Future<void> updateProfile({
    required Map<String, String> fields,
    List<MapEntry<String, String>>? repeatedFields,
    Map<String, File>? files,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final previousCategoryId = _profile?.categoryId;
      final requestedCategoryId = fields['InterstedInCategoryId']?.trim();
      debugPrint('--- STARTING PROFILE UPDATE (PATCH) ---');
      await _repository.updateProfile(
        fields: fields,
        repeatedFields: repeatedFields,
        files: files,
      );
      debugPrint('--- PROFILE UPDATE SUCCESS. REFETCHING PROFILE ---');
      await fetchProfile(
        previousCategoryId: previousCategoryId,
        preferredCategoryId: requestedCategoryId,
      );
    } catch (e) {
      debugPrint('--- ERROR IN UPDATE PROFILE: $e ---');
      _errorMessage = AppErrorParser.parse(e);
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// POST /Account/candidate/uploadfile
  Future<void> uploadFile(File file) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      debugPrint('--- STARTING FILE UPLOAD ---');
      await _repository.uploadFile(file);
      debugPrint('--- FILE UPLOAD SUCCESS. REFETCHING PROFILE ---');
      await fetchProfile();
    } catch (e) {
      debugPrint('--- ERROR IN UPLOAD FILE: $e ---');
      _errorMessage = AppErrorParser.parse(e);
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (token != null && token.isNotEmpty) {
        await _notificationsRepository.removeDeviceToken(token);
      }
      await FirebaseMessaging.instance.deleteToken();
      debugPrint('=== FCM: Token deleted on logout ===');
    } catch (e) {
      debugPrint('=== FCM: Error deleting token: $e ===');
    }

    await _storage.clear();
    resetSessionState();
  }

  @override
  void resetSessionState({bool notify = true}) {
    _sessionVersion++;
    _profile = null;
    _isLoading = false;
    _errorMessage = null;
    if (notify) notifyListeners();
  }
}
