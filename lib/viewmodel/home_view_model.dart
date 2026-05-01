import 'package:flutter/material.dart';
import '../model/home_model.dart';
import '../repository/home_repository.dart';
import '../repository/profile_repository.dart';

class HomeViewModel extends ChangeNotifier {
  final HomeRepository _repository = HomeRepository();

  List<StatModel> _stats = [];
  List<StatModel> get stats => _stats;

  List<JobModel> _jobs = [];
  List<JobModel> get jobs => _jobs;

  String _userName = '';
  String get userName => _userName;

  String _userProfileImage = '';
  String get userProfileImage => _userProfileImage;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  int _selectedIndex = 0; // 0 is Home
  int get selectedIndex => _selectedIndex;

  Future<void> fetchHomeData() async {
    _isLoading = true;
    notifyListeners();

    try {
      final results = await Future.wait([
        _repository.getStats(),
        _repository.getRecommendedJobs(),
        _repository.getUserName(),
      ]);

      // Fetch profile to guarantee we get the correct avatarUrl
      final profileRepo = ProfileRepository();
      try {
        final profile = await profileRepo.getUserProfile();
        _userProfileImage = profile.avatarUrl;
        if (_userName.isEmpty) {
          _userName = profile.name;
        }
      } catch (e) {
        debugPrint('Failed to load profile for avatar: $e');
      }

      _stats = results[0] as List<StatModel>;
      _jobs = results[1] as List<JobModel>;
      if (_userName.isEmpty) {
        _userName = results[2] as String;
      }
    } catch (e) {
      debugPrint('Error fetching home data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setTabIndex(int index) {
    _selectedIndex = index;
    notifyListeners();
  }
}

