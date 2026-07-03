import 'dart:async';

import 'package:flutter/material.dart';
import '../model/interview_model.dart';
import '../model/home/home_model.dart';
import '../model/notification_model.dart';
import '../model/profile_model.dart';
import '../repository/home_repository.dart';
import '../repository/profile_repository.dart';
import '../repository/search_repository.dart';
import '../services/push_notification_service.dart';
import '../utils/app_error_parser.dart';
import '../utils/search_text_normalizer.dart';
import 'session_resettable.dart';

class HomeViewModel extends ChangeNotifier implements SessionResettable {
  final HomeRepository _repository;
  final ProfileRepository _profileRepository;
  final SearchRepository _searchRepository;
  final PushNotificationService? _pushNotificationService;
  StreamSubscription<NotificationModel>? _pushSubscription;
  Future<void>? _activeFetch;
  bool _queuedForceRefresh = false;
  int _sessionVersion = 0;

  final Set<String> _optimisticAppliedJobIds = <String>{};
  int? _optimisticReviewCountBase;
  int? _optimisticSentCountBase;

  HomeViewModel({
    HomeRepository? repository,
    ProfileRepository? profileRepository,
    SearchRepository? searchRepository,
    PushNotificationService? pushNotificationService,
  }) : _repository = repository ?? HomeRepository(),
       _profileRepository = profileRepository ?? ProfileRepository(),
       _searchRepository = searchRepository ?? SearchRepository(),
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

  List<StatModel> _authoritativeStats = [];
  List<StatModel> get stats {
    if (_authoritativeStats.isEmpty && _optimisticAppliedJobIds.isEmpty) {
      return _authoritativeStats;
    }

    return _withOptimisticApplicationStats(
      _ensureCoreStats(_authoritativeStats),
    );
  }

  List<JobModel> _jobs = [];
  List<JobModel> get jobs => _jobs;

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  Timer? _searchDebounce;
  List<JobModel> _searchResults = [];
  bool _isSearching = false;
  bool get isSearching => _isSearching;

  /// Returns jobs filtered by the current search query (backend search).
  List<JobModel> get filteredJobs {
    final query = SearchTextNormalizer.normalize(_searchQuery);
    if (query.isEmpty) return _jobs;

    return _searchResults;
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

  Future<void> fetchHomeData({bool forceRefresh = false}) {
    final activeFetch = _activeFetch;
    if (activeFetch != null) {
      if (forceRefresh) {
        _queuedForceRefresh = true;
      }
      return activeFetch;
    }

    late final Future<void> fetch;
    final requestVersion = _sessionVersion;
    fetch =
        _runFetchQueue(
          initialForceRefresh: forceRefresh,
          requestVersion: requestVersion,
        ).whenComplete(() {
          if (identical(_activeFetch, fetch)) {
            _activeFetch = null;
          }
        });
    _activeFetch = fetch;
    return fetch;
  }

  Future<void> _runFetchQueue({
    required bool initialForceRefresh,
    required int requestVersion,
  }) async {
    var forceRefresh = initialForceRefresh;

    do {
      _queuedForceRefresh = false;
      await _fetchHomeData(forceRefresh: forceRefresh);
      forceRefresh = true;
    } while (_queuedForceRefresh && requestVersion == _sessionVersion);
  }

  Future<void> _fetchHomeData({bool forceRefresh = false}) async {
    final requestVersion = _sessionVersion;
    final hasExistingData =
        stats.isNotEmpty ||
        _jobs.isNotEmpty ||
        _optimisticAppliedJobIds.isNotEmpty;
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

      final fetchedStats = results[0] as List<StatModel>;
      _reconcileOptimisticApplicationStats(fetchedStats);
      _authoritativeStats = _ensureCoreStats(fetchedStats);
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
      if (_authoritativeStats.isEmpty) {
        _authoritativeStats = _defaultStats();
      }
    } finally {
      if (requestVersion == _sessionVersion) {
        _isLoading = false;
        _isRefreshing = false;
        notifyListeners();
      }
    }
  }

  void handleJobApplied(String jobId) {
    final normalizedJobId = jobId.trim();
    if (normalizedJobId.isEmpty) return;

    final added = _optimisticAppliedJobIds.add(normalizedJobId);
    if (added && _authoritativeStats.isNotEmpty) {
      _optimisticReviewCountBase ??= _statCountFor(StatType.review);
      _optimisticSentCountBase ??= _statCountFor(StatType.sent);
    }

    if (added) notifyListeners();
    unawaited(fetchHomeData(forceRefresh: true));
  }

  void handleInterviewStatusChanged({
    required InterviewStatus previousStatus,
    required InterviewStatus nextStatus,
  }) {
    final delta =
        (nextStatus == InterviewStatus.confirmed ? 1 : 0) -
        (previousStatus == InterviewStatus.confirmed ? 1 : 0);

    if (delta != 0) {
      final coreStats = _ensureCoreStats(
        _authoritativeStats.isEmpty ? _defaultStats() : _authoritativeStats,
      );
      final currentCount = _statCountIn(coreStats, StatType.interview);
      final nextCount = (currentCount + delta).clamp(0, 1 << 31);

      _authoritativeStats = coreStats.map((stat) {
        if (stat.type != StatType.interview) return stat;
        return StatModel(
          count: nextCount.toString(),
          label: stat.label,
          type: stat.type,
        );
      }).toList();

      notifyListeners();
    }

    unawaited(fetchHomeData(forceRefresh: true));
  }

  List<StatModel> _withOptimisticApplicationStats(List<StatModel> stats) {
    if (_optimisticAppliedJobIds.isEmpty) return stats;

    final optimisticCount = _optimisticAppliedJobIds.length;
    final reviewTarget =
        (_optimisticReviewCountBase ?? _statCountIn(stats, StatType.review)) +
        optimisticCount;
    final sentTarget =
        (_optimisticSentCountBase ?? _statCountIn(stats, StatType.sent)) +
        optimisticCount;

    return _withStatMinimums(stats, {
      StatType.review: reviewTarget,
      StatType.sent: sentTarget,
    });
  }

  void _reconcileOptimisticApplicationStats(List<StatModel> fetchedStats) {
    if (_optimisticAppliedJobIds.isEmpty) return;

    final fetchedCoreStats = _ensureCoreStats(fetchedStats);
    final optimisticCount = _optimisticAppliedJobIds.length;

    if (_optimisticReviewCountBase == null ||
        _optimisticSentCountBase == null) {
      _clearOptimisticApplicationStats();
      return;
    }

    final reviewTarget = _optimisticReviewCountBase! + optimisticCount;
    final sentTarget = _optimisticSentCountBase! + optimisticCount;

    if (_statCountIn(fetchedCoreStats, StatType.review) >= reviewTarget &&
        _statCountIn(fetchedCoreStats, StatType.sent) >= sentTarget) {
      _clearOptimisticApplicationStats();
    }
  }

  List<StatModel> _withStatMinimums(
    List<StatModel> stats,
    Map<StatType, int> minimums,
  ) {
    return stats.map((stat) {
      final minimum = minimums[stat.type];
      if (minimum == null || _readStatCount(stat.count) >= minimum) {
        return stat;
      }

      return StatModel(
        count: minimum.toString(),
        label: stat.label,
        type: stat.type,
      );
    }).toList();
  }

  List<StatModel> _ensureCoreStats(List<StatModel> stats) {
    StatModel? findStat(StatType type) {
      for (final stat in stats) {
        if (stat.type == type) return stat;
      }
      return null;
    }

    return [
      findStat(StatType.interview) ?? _defaultStat(StatType.interview),
      findStat(StatType.review) ?? _defaultStat(StatType.review),
      findStat(StatType.sent) ?? _defaultStat(StatType.sent),
    ];
  }

  List<StatModel> _defaultStats() {
    return [
      _defaultStat(StatType.interview),
      _defaultStat(StatType.review),
      _defaultStat(StatType.sent),
    ];
  }

  StatModel _defaultStat(StatType type) {
    switch (type) {
      case StatType.interview:
        return StatModel(
          count: '0',
          label: '\u0645\u0642\u0627\u0628\u0644\u0627\u062a',
          type: type,
        );
      case StatType.review:
        return StatModel(
          count: '0',
          label:
              '\u0642\u064a\u062f \u0627\u0644\u0645\u0631\u0627\u062c\u0639\u0629',
          type: type,
        );
      case StatType.sent:
        return StatModel(
          count: '0',
          label:
              '\u0637\u0644\u0628\u0627\u062a \u0645\u0631\u0633\u0644\u0629',
          type: type,
        );
      case StatType.unknown:
        return StatModel(count: '0', label: '', type: type);
    }
  }

  int _statCountFor(StatType type) => _statCountIn(_authoritativeStats, type);

  int _statCountIn(List<StatModel> stats, StatType type) {
    for (final stat in stats) {
      if (stat.type == type) return _readStatCount(stat.count);
    }
    return 0;
  }

  int _readStatCount(String count) {
    return int.tryParse(count.trim()) ?? 0;
  }

  void _clearOptimisticApplicationStats() {
    _optimisticAppliedJobIds.clear();
    _optimisticReviewCountBase = null;
    _optimisticSentCountBase = null;
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
    if (_searchQuery == query) return;
    _searchQuery = query;
    
    if (_searchDebounce?.isActive ?? false) _searchDebounce!.cancel();

    if (query.trim().isEmpty) {
      _searchResults.clear();
      _isSearching = false;
      notifyListeners();
      return;
    }

    _isSearching = true;
    notifyListeners();

    _searchDebounce = Timer(const Duration(milliseconds: 500), () {
      _performSearch(query);
    });
  }

  Future<void> _performSearch(String query) async {
    try {
      final results = await _searchRepository.searchJobs(query: query);
      if (_searchQuery == query) {
        _searchResults = results;
      }
    } catch (e) {
      if (_searchQuery == query) {
        _errorMessage = AppErrorParser.parse(e);
        _searchResults = [];
      }
    } finally {
      if (_searchQuery == query) {
        _isSearching = false;
        notifyListeners();
      }
    }
  }

  void clearSearch({bool notify = true}) {
    if (_searchQuery.isEmpty) return;
    _searchQuery = '';
    _searchDebounce?.cancel();
    _searchResults.clear();
    _isSearching = false;
    if (notify) notifyListeners();
  }

  @override
  void resetSessionState({bool notify = true}) {
    _sessionVersion++;
    _activeFetch = null;
    _queuedForceRefresh = false;
    _clearOptimisticApplicationStats();
    _repository.clearCache();
    _authoritativeStats = [];
    _jobs = [];
    _searchQuery = '';
    _searchDebounce?.cancel();
    _searchResults.clear();
    _isSearching = false;
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
    _searchDebounce?.cancel();
    _pushSubscription?.cancel();
    super.dispose();
  }
}
