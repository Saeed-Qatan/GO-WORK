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

  ProfileViewModel() {
    fetchProfile();
  }

  Future<void> fetchProfile() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _profile = await _repository.getUserProfile();
    } catch (e) {
      _errorMessage = 'حدث خطأ أثناء جلب الملف الشخصي: $e';
      debugPrint('Error fetching profile: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateProfile(Map<String, dynamic> data) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.updateProfile(data);
      await fetchProfile(); // Refresh after update
    } catch (e) {
      _errorMessage = 'حدث خطأ أثناء تحديث الملف الشخصي: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _storage.clear();
    _profile = null;
    notifyListeners();
    // Navigation to login would typically happen in the view after calling this
  }
}
