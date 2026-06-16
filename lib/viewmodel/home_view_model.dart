import 'dart:async';

import 'package:flutter/material.dart';
import '../model/home/home_model.dart';
import '../model/notification_model.dart';
import '../model/profile_model.dart';
import '../repository/home_repository.dart';
import '../repository/profile_repository.dart';
import '../services/push_notification_service.dart';
import '../utils/app_error_parser.dart';
import 'session_resettable.dart';

class HomeViewModel extends ChangeNotifier implements SessionResettable {
  final HomeRepository _repository;
  final ProfileRepository _profileRepository;
  final PushNotificationService? _pushNotificationService;
  StreamSubscription<NotificationModel>? _pushSubscription;
  int _sessionVersion = 0;

  HomeViewModel({
    HomeRepository? repository,
    ProfileRepository? profileRepository,
    PushNotificationService? pushNotificationService,
  }) : _repository = repository ?? HomeRepository(),
       _profileRepository = profileRepository ?? ProfileRepository(),
       _pushNotificationService = pushNotificationService {
    _subscribeToLiveNotifications();
  }

  void _subscribeToLiveNotifications() {
    _pushSubscription = _pushNotificationService?.onNotificationReceived.listen((
      notification,
    ) {
      debugPrint(
        '=== HOME VM: Push notification received, refreshing home data automatically ===',
      );
      unawaited(fetchHomeData(forceRefresh: true));
    });
  }

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

  bool _isRefreshing = false;
  bool get isRefreshing => _isRefreshing;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  int _selectedIndex = 0; // 0 is Home
  int get selectedIndex => _selectedIndex;

  Future<void> fetchHomeData({bool forceRefresh = false}) async {
    final requestVersion = _sessionVersion;
    final hasExistingData = _stats.isNotEmpty || _jobs.isNotEmpty;
    if (forceRefresh) {
      _repository.clearCache();
    }
    if (forceRefresh && hasExistingData) {
      _isRefreshing = true;
    } else {
      _isLoading = true;
    }
    _errorMessage = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        _repository.getStats(),
        _repository.getRecommendedJobs(),
        _repository.getUserName(),
      ]);

      if (requestVersion != _sessionVersion) return;

      _stats = results[0] as List<StatModel>;
      _jobs = results[1] as List<JobModel>;
      if (_userName.isEmpty) {
        _userName = results[2] as String;
      }

      notifyListeners();
      unawaited(_refreshProfileSummary(requestVersion));
    } catch (e) {
      if (requestVersion != _sessionVersion) return;
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
      if (requestVersion == _sessionVersion) {
        _isLoading = false;
        _isRefreshing = false;
        notifyListeners();
      }
    }
  }

  Future<void> _refreshProfileSummary(int requestVersion) async {
    try {
      final profile = await _profileRepository.getUserProfile();
      if (requestVersion != _sessionVersion) return;
      seedProfileSummary(profile);
    } catch (e) {
      debugPrint('Failed to load profile for avatar: $e');
    }
  }

  void seedProfileSummary(ProfileModel profile, {bool notify = true}) {
    final nextName = profile.name.trim();
    final nextImage = profile.avatarUrl.trim();
    var changed = false;

    if (nextName.isNotEmpty && nextName != _userName) {
      _userName = nextName;
      changed = true;
    }
    if (nextImage != _userProfileImage) {
      _userProfileImage = nextImage;
      changed = true;
    }

    if (changed && notify) notifyListeners();
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

  @override
  void resetSessionState({bool notify = true}) {
    _sessionVersion++;
    _repository.clearCache();
    _stats = [];
    _jobs = [];
    _searchQuery = '';
    _userName = '';
    _userProfileImage = '';
    _isLoading = false;
    _isRefreshing = false;
    _errorMessage = null;
    _selectedIndex = 0;
    if (notify) notifyListeners();
  }

  @override
  void dispose() {
    _pushSubscription?.cancel();
    super.dispose();
  }
}
