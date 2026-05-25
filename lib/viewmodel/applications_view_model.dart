import 'package:flutter/material.dart';

import '../model/application_model.dart';
import '../repository/applications_repository.dart';
import '../utils/app_error_parser.dart';

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

  Future<String?> withdrawApplication(String applicationId) async {
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
