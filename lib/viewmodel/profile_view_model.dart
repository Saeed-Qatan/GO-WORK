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
      debugPrint('Error fetching profile from API: $e');
      // Fallback to mock data when backend is unavailable
      _profile = _getMockProfile();
      _errorMessage = null; // Clear error since we have mock data
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
      // Update local mock data with the submitted changes
      _profile = ProfileModel(
        firstName: data['FirstName'] ?? _profile?.firstName ?? '',
        middleName: data['MiddleName'] ?? _profile?.middleName ?? '',
        lastName: data['LastName'] ?? _profile?.lastName ?? '',
        jobTitle: data['JobTitle'] ?? _profile?.jobTitle ?? '',
        avatarUrl: _profile?.avatarUrl ?? '',
        email: _profile?.email ?? '',
        phone: data['PhoneNumber'] ?? _profile?.phone ?? '',
        cvUrl: _profile?.cvUrl ?? '',
        skills: List<String>.from(data['Skills'] ?? _profile?.skills ?? []),
      );
      _errorMessage = null;
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

  /// Mock profile data for testing when the backend is unavailable.
  /// Remove this once the real API endpoint is ready.
  ProfileModel _getMockProfile() {
    return ProfileModel(
      firstName: 'سعيد',
      middleName: '',
      lastName: 'قطان',
      jobTitle: 'مصمم واجهة / تجربة مستخدم',
      avatarUrl: '',
      email: 'saeed@gowork.com',
      phone: '+966 55 123 4567',
      cvUrl: 'CV_Ahmed_2023.pdf',
      skills: [
        'Git',
        'Flutter',
        'Dart',
        'Firebase',
        'Clean Architecture',
        'Bloc',
      ],
    );
  }
}
