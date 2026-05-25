import 'package:flutter/material.dart';
import '../model/home/home_model.dart';
import '../repository/home_repository.dart';
import '../repository/profile_repository.dart';
import '../utils/app_error_parser.dart';

class HomeViewModel extends ChangeNotifier {
  final HomeRepository _repository = HomeRepository();

  List<StatModel> _stats = [];
  List<StatModel> get stats => _stats;

  List<JobModel> _jobs = [];
  List<JobModel> get jobs => _jobs;

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  /// Returns jobs filtered by the current search query (client-side).
  List<JobModel> get filteredJobs {
    if (_searchQuery.trim().isEmpty) return _jobs;
    final q = _searchQuery.trim().toLowerCase();
    return _jobs.where((job) {
      return job.title.toLowerCase().contains(q) ||
          job.company.toLowerCase().contains(q) ||
          job.category.toLowerCase().contains(q) ||
          job.location.toLowerCase().contains(q);
    }).toList();
  }

  String _userName = '';
  String get userName => _userName;

  String _userProfileImage = '';
  String get userProfileImage => _userProfileImage;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  int _selectedIndex = 0; // 0 is Home
  int get selectedIndex => _selectedIndex;

  Future<void> fetchHomeData({bool forceRefresh = false}) async {
    if (forceRefresh) {
      _repository.clearCache();
    }
    _isLoading = true;
    _errorMessage = null;
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
      _errorMessage = AppErrorParser.parse(e);
      // Ensure we don't display completely empty stats which would break UI
      if (_stats.isEmpty) {
        _stats = [
          StatModel(count: '0', label: 'مقابلات', type: StatType.interview),
          StatModel(count: '0', label: 'قيد المراجعة', type: StatType.review),
          StatModel(count: '0', label: 'طلبات مرسلة', type: StatType.sent),
        ];
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setTabIndex(int index) {
    _selectedIndex = index;
    notifyListeners();
  }

  /// Updates the search query and notifies listeners to re-filter jobs.
  void onSearchChanged(String query) {
    _searchQuery = query;
    notifyListeners();
  }
}
