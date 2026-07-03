import 'dart:convert';
import 'package:flutter/material.dart';
import '../model/applications/application_model.dart';
import '../repository/applications_repository.dart';
import '../utils/app_error_parser.dart';
import '../utils/local_storage.dart';
import 'job_application_state_view_model.dart';
import 'session_resettable.dart';

class ApplicationsViewModel extends ChangeNotifier
    implements SessionResettable {
  final IApplicationsRepository _repository;
  final LocalStorage _storage;
  int _sessionVersion = 0;
  List<ApplicationModel> _allApplications = [];
  List<ApplicationModel> _filteredApplications = [];
  List<ApplicationStatusModel> _statuses = [];

  int _selectedFilterIndex = 0;
  bool _isLoading = false;
  String? _errorMessage;

  ApplicationsViewModel({
    IApplicationsRepository? repository,
    LocalStorage? storage,
    bool autoFetch = true,
  }) : _repository = repository ?? ApplicationsRepository(),
       _storage = storage ?? LocalStorage() {
    if (autoFetch) fetchApplications();
  }

  List<ApplicationFilterTab> get filterTabItems {
    final tabs = <ApplicationFilterTab>[const ApplicationFilterTab.all()];
    final seen = <String>{'all'};

    for (final status in _statuses) {
      if (status.label == 'تم التقديم') continue;
      final tab = ApplicationFilterTab.status(status);
      if (seen.add(tab.uniqueKey)) tabs.add(tab);
    }

    return tabs;
  }

  List<String> get filterTabs {
    return filterTabItems.map((tab) => tab.label).toList();
  }

  List<ApplicationModel> get applications => _filteredApplications;

  int get selectedFilterIndex => _selectedFilterIndex;

  bool get isLoading => _isLoading;

  String? get errorMessage => _errorMessage;

  Future<void> fetchApplications({bool showLoading = true}) async {
    final requestVersion = _sessionVersion;
    if (showLoading) _isLoading = true;
    _errorMessage = null;
    if (showLoading) notifyListeners();

    try {
      final data = await _repository.getApplicationsData();
      if (requestVersion != _sessionVersion) return;
      _statuses = data.statuses;
      _allApplications = data.applications;

      // Merge back any persistent optimistic applications that are not yet returned by the backend
      final optimisticApps = await _loadOptimisticApplications();
      final appliedStatus = _appliedStatus;
      for (var optApp in optimisticApps) {
        final exists = _allApplications.any(
          (item) => item.jobId.trim() == optApp.jobId.trim(),
        );
        if (!exists) {
          if (appliedStatus != null) {
            optApp = optApp.withStatus(appliedStatus);
          }
          _allApplications.insert(0, optApp);
        } else {
          // The backend has finally registered the application! We can clean up our local storage
          await _removeOptimisticApplication(optApp.jobId);
          if (requestVersion != _sessionVersion) return;
        }
      }

      if (_selectedFilterIndex >= filterTabItems.length) {
        _selectedFilterIndex = 0;
      }

      _applyFilter();
    } catch (e) {
      if (requestVersion != _sessionVersion) return;
      _errorMessage = AppErrorParser.parse(e);
      _allApplications = [];
      _filteredApplications = [];
      _statuses = [];
      _selectedFilterIndex = 0;
    } finally {
      if (requestVersion == _sessionVersion) {
        if (showLoading) _isLoading = false;
        notifyListeners();
      }
    }
  }

  void setFilterIndex(int index) {
    if (index < 0 || index >= filterTabItems.length) return;
    _selectedFilterIndex = index;
    _applyFilter();
    notifyListeners();
  }

  Future<String?> withdrawApplication(
    String applicationId, {
    JobApplicationStateViewModel? applicationState,
  }) async {
    try {
      final currentApplication = _findApplication(applicationId);
      await _repository.withdrawApplication(applicationId);
      final movedApplication = _moveApplicationToWithdrawnStatus(applicationId);

      await fetchApplications(showLoading: false);
      _restoreWithdrawnApplicationIfMissing(
        movedApplication ?? currentApplication,
      );
      _moveApplicationToWithdrawnStatus(applicationId);
      _selectWithdrawnTab();

      final jobId = movedApplication?.jobId ?? currentApplication?.jobId;
      if (jobId != null && jobId.isNotEmpty) {
        applicationState?.markWithdrawn(jobId);
      }

      return null;
    } catch (e) {
      notifyListeners();
      return AppErrorParser.parse(e);
    }
  }

  ApplicationModel? _moveApplicationToWithdrawnStatus(String applicationId) {
    final withdrawnStatus = _withdrawnStatus;
    if (withdrawnStatus == null) return null;

    ApplicationModel? movedApplication;

    _allApplications = _allApplications.map((application) {
      if (application.id != applicationId) return application;
      movedApplication = application.withStatus(withdrawnStatus);
      return movedApplication!;
    }).toList();

    _applyFilter();
    notifyListeners();

    return movedApplication;
  }

  void _restoreWithdrawnApplicationIfMissing(ApplicationModel? application) {
    if (application == null) return;
    final withdrawnStatus = _withdrawnStatus;
    if (withdrawnStatus == null) return;

    final exists = _allApplications.any((item) => item.id == application.id);
    if (exists) return;

    _allApplications = [
      application.withStatus(withdrawnStatus),
      ..._allApplications,
    ];
  }

  ApplicationModel? _findApplication(String applicationId) {
    for (final application in _allApplications) {
      if (application.id == applicationId) return application;
    }

    return null;
  }

  ApplicationStatusModel? get _withdrawnStatus {
    for (final status in _statuses) {
      if (status.isWithdrawn) return status;
    }

    return null;
  }

  void _selectWithdrawnTab() {
    final index = filterTabItems.indexWhere(
      (tab) => tab.status?.isWithdrawn ?? false,
    );
    if (index == -1) return;

    _selectedFilterIndex = index;
    _applyFilter();
    notifyListeners();
  }

  void _applyFilter() {
    if (_selectedFilterIndex >= filterTabItems.length) {
      _selectedFilterIndex = 0;
    }
    final selectedTab = filterTabItems[_selectedFilterIndex];
    _filteredApplications = _allApplications
        .where((app) => app.statusLabel != 'تم التقديم')
        .where(selectedTab.matches)
        .toList();
  }

  Future<List<ApplicationModel>> _loadOptimisticApplications() async {
    try {
      final jsonStr = await _storage.getScopedString('optimistic_applications');
      if (jsonStr == null || jsonStr.isEmpty) return [];
      final List<dynamic> decoded = json.decode(jsonStr);
      return decoded.map((item) => ApplicationModel.fromJson(item)).toList();
    } catch (e) {
      debugPrint('Error loading optimistic applications: $e');
      return [];
    }
  }

  Future<void> _saveOptimisticApplication(ApplicationModel app) async {
    try {
      final currentList = await _loadOptimisticApplications();
      currentList.removeWhere((item) => item.jobId == app.jobId);
      currentList.add(app);
      final jsonStr = json.encode(
        currentList.map((item) => item.toJson()).toList(),
      );
      await _storage.saveScopedString('optimistic_applications', jsonStr);
    } catch (e) {
      debugPrint('Error saving optimistic application: $e');
    }
  }

  Future<void> _removeOptimisticApplication(String jobId) async {
    try {
      final currentList = await _loadOptimisticApplications();
      currentList.removeWhere((item) => item.jobId == jobId);
      final jsonStr = json.encode(
        currentList.map((item) => item.toJson()).toList(),
      );
      await _storage.saveScopedString('optimistic_applications', jsonStr);
    } catch (e) {
      debugPrint('Error removing optimistic application: $e');
    }
  }

  /// Returns the "Applied" status from the backend statuses list.
  ApplicationStatusModel? get _appliedStatus {
    for (final status in _statuses) {
      final normalized = ApplicationStatusMatcher.normalize(status.value);
      final label = status.label.toLowerCase();
      if (normalized == '0' ||
          normalized == '1' ||
          normalized == 'interviewed' ||
          normalized.contains('submit') ||
          normalized.contains('applied') ||
          normalized.contains('pending') ||
          normalized.contains('review') ||
          label.contains('تقديم') ||
          label.contains('مراجعة') ||
          label.contains('applied') ||
          label.contains('pending')) {
        return status;
      }
    }
    // Fallback: use the first status if available
    return _statuses.isNotEmpty ? _statuses.first : null;
  }

  /// Optimistically adds an application locally from job data.
  /// Called immediately after a successful apply API call so the
  /// Applications page reflects the new entry without waiting for
  /// the backend to return it via fetchApplications.
  void addOptimisticApplication({
    required String jobId,
    required String jobTitle,
    required String company,
    String companyLogo = '',
  }) async {
    final trimmedJobId = jobId.trim();
    // Avoid duplicates
    final exists = _allApplications.any(
      (app) => app.jobId.trim() == trimmedJobId,
    );
    if (exists) return;

    final appliedStatus = _appliedStatus;
    final now = DateTime.now().toIso8601String();

    final optimisticApp = ApplicationModel(
      id: 'local_$trimmedJobId',
      jobId: trimmedJobId,
      role: jobTitle,
      company: company,
      companyLogo: companyLogo,
      date: now,
      statusId: appliedStatus?.id ?? '0',
      statusValue: appliedStatus?.value ?? '0',
      statusRaw: appliedStatus?.value ?? '0',
      statusLabel: appliedStatus?.label ?? 'تم التقديم',
      statusColorHex: appliedStatus?.foregroundColorHex,
      statusBackgroundColorHex: appliedStatus?.backgroundColorHex,
      canWithdraw: true,
    );

    _allApplications.insert(0, optimisticApp);
    _applyFilter();
    notifyListeners();

    // Persist to local storage
    await _saveOptimisticApplication(optimisticApp);
  }

  @override
  void resetSessionState({bool notify = true}) {
    _sessionVersion++;
    _allApplications = [];
    _filteredApplications = [];
    _statuses = [];
    _selectedFilterIndex = 0;
    _isLoading = false;
    _errorMessage = null;
    if (notify) notifyListeners();
  }
}

class ApplicationFilterTab {
  final String label;
  final ApplicationStatusModel? status;
  final bool isAll;

  const ApplicationFilterTab._({
    required this.label,
    this.status,
    this.isAll = false,
  });

  const ApplicationFilterTab.all() : this._(label: 'الكل', isAll: true);

  factory ApplicationFilterTab.status(ApplicationStatusModel status) {
    return ApplicationFilterTab._(label: status.label, status: status);
  }

  bool matches(ApplicationModel application) {
    if (isAll) return true;
    return status?.matches(application) ?? false;
  }

  String get uniqueKey {
    if (isAll) return 'all';
    return ApplicationStatusMatcher.normalize(status?.value ?? label);
  }
}
