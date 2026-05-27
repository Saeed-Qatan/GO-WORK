import 'dart:convert';
import 'package:flutter/material.dart';
import '../model/applications/application_model.dart';
import '../repository/applications_repository.dart';
import '../utils/app_error_parser.dart';
import '../utils/local_storage.dart';
import 'job_application_state_view_model.dart';

class ApplicationsViewModel extends ChangeNotifier {
  final IApplicationsRepository _repository;
  List<ApplicationModel> _allApplications = [];
  List<ApplicationModel> _filteredApplications = [];
  List<ApplicationStatusModel> _statuses = [];

  int _selectedFilterIndex = 0;
  bool _isLoading = false;
  String? _errorMessage;

  ApplicationsViewModel({
    IApplicationsRepository? repository,
    bool autoFetch = true,
  }) : _repository = repository ?? ApplicationsRepository() {
    if (autoFetch) fetchApplications();
  }

  List<ApplicationFilterTab> get filterTabItems {
    final tabs = <ApplicationFilterTab>[const ApplicationFilterTab.all()];
    final seen = <String>{'all'};

    for (final status in _statuses) {
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
    if (showLoading) _isLoading = true;
    _errorMessage = null;
    if (showLoading) notifyListeners();

    try {
      final data = await _repository.getApplicationsData();
      _statuses = data.statuses;
      _allApplications = data.applications;

      // Merge locally stored withdrawn applications
      final withdrawnApps = await _loadWithdrawnApplications();
      final withdrawnStatus = _withdrawnStatus;
      if (withdrawnStatus != null) {
        for (final localApp in withdrawnApps) {
          final exists = _allApplications.any((item) => item.id == localApp.id);
          if (!exists) {
            _allApplications.insert(0, localApp.withStatus(withdrawnStatus));
          }
        }
      }

      if (_selectedFilterIndex >= filterTabItems.length) {
        _selectedFilterIndex = 0;
      }

      _applyFilter();
    } catch (e) {
      _errorMessage = AppErrorParser.parse(e);
      _allApplications = [];
      _filteredApplications = [];
      _statuses = [];
      _selectedFilterIndex = 0;
    } finally {
      if (showLoading) _isLoading = false;
      notifyListeners();
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

      // Save to persistent storage
      final withdrawnStatus = _withdrawnStatus;
      if (movedApplication != null) {
        await _saveWithdrawnApplication(movedApplication);
      } else if (currentApplication != null && withdrawnStatus != null) {
        await _saveWithdrawnApplication(currentApplication.withStatus(withdrawnStatus));
      }

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
    final selectedTab = filterTabItems[_selectedFilterIndex];
    _filteredApplications = _allApplications
        .where(selectedTab.matches)
        .toList();
  }

  Future<List<ApplicationModel>> _loadWithdrawnApplications() async {
    try {
      final jsonStr = await LocalStorage().getString('withdrawn_applications');
      if (jsonStr == null || jsonStr.isEmpty) return [];
      final List<dynamic> decoded = json.decode(jsonStr);
      return decoded.map((item) => ApplicationModel.fromJson(item)).toList();
    } catch (e) {
      debugPrint('Error loading withdrawn applications: $e');
      return [];
    }
  }

  Future<void> _saveWithdrawnApplication(ApplicationModel app) async {
    try {
      final currentList = await _loadWithdrawnApplications();
      currentList.removeWhere((item) => item.id == app.id);
      currentList.add(app);
      final jsonStr = json.encode(currentList.map((item) => item.toJson()).toList());
      await LocalStorage().saveString('withdrawn_applications', jsonStr);
    } catch (e) {
      debugPrint('Error saving withdrawn application: $e');
    }
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
