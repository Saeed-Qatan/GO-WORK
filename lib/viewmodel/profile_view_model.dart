import 'dart:io';
import 'package:flutter/material.dart';
import '../model/profile_model.dart';
import '../repository/profile_repository.dart';
import '../utils/local_storage.dart';

class ProfileViewModel extends ChangeNotifier {
  final ProfileRepository _repository = ProfileRepository();
  final LocalStorage _storage = LocalStorage();
  ProfileModel? _profile;
  ProfileModel? get profile => _profile;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  ProfileViewModel();

  Future<void> fetchProfile() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _profile = await _repository.getUserProfile();
    } catch (e) {
      debugPrint('Error fetching profile: $e');
      _errorMessage = 'حدث خطأ أثناء تحميل الملف الشخصي: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// PATCH /Account/Candidate/UpdateProfile — form-data with all fields + files
  Future<void> updateProfile({
    required Map<String, String> fields,
    List<MapEntry<String, String>>? repeatedFields,
    Map<String, File>? files,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      print('--- STARTING PROFILE UPDATE (PATCH) ---');
      await _repository.updateProfile(
        fields: fields,
        repeatedFields: repeatedFields,
        files: files,
      );
      print('--- PROFILE UPDATE SUCCESS. REFETCHING PROFILE ---');
      await fetchProfile();
    } catch (e) {
      print('--- ERROR IN UPDATE PROFILE: $e ---');
      _errorMessage = 'حدث خطأ أثناء تحديث الملف الشخصي: $e';
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
      print('--- STARTING FILE UPLOAD ---');
      await _repository.uploadFile(file);
      print('--- FILE UPLOAD SUCCESS. REFETCHING PROFILE ---');
      await fetchProfile();
    } catch (e) {
      print('--- ERROR IN UPLOAD FILE: $e ---');
      _errorMessage = 'حدث خطأ أثناء رفع الملف: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _storage.clear();
    _profile = null;
    notifyListeners();
  }
}
