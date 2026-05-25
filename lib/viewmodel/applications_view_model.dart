import 'package:flutter/material.dart';
import '../model/application_model.dart';
import '../repository/applications_repository.dart';
import '../utils/status_translator.dart';
import '../utils/app_error_parser.dart';

class ApplicationsViewModel extends ChangeNotifier {
  final ApplicationsRepository _repository = ApplicationsRepository();
  List<ApplicationModel> _allApplications = [];
  List<ApplicationModel> _filteredApplications = [];
  List<dynamic> _statuses = [];

  List<ApplicationFilterTab> get filterTabItems {
    final tabs = <ApplicationFilterTab>[
      const ApplicationFilterTab(label: 'الكل', isAll: true),
    ];

    final rawStatusValues = _statuses.map(_extractStatusValue).whereType<String>();

    for (final rawStatus in rawStatusValues) {
      _addUniqueTab(tabs, ApplicationFilterTab.fromRaw(rawStatus));
    }

    for (final application in _allApplications) {
      _addUniqueTab(
        tabs,
        ApplicationFilterTab(
          label: application.displayStatusName,
          status: application.status,
          rawValue: application.rawStatusName,
        ),
      );
    }

    return tabs;
  }

  List<String> get filterTabs {
    return filterTabItems.map((tab) => tab.label).toList();
  }

  List<ApplicationModel> get applications => _filteredApplications;

  int _selectedFilterIndex = 0;
  int get selectedFilterIndex => _selectedFilterIndex;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  ApplicationsViewModel() {
    fetchApplications();
  }

  Future<void> fetchApplications({bool showLoading = true}) async {
    if (showLoading) _isLoading = true;
    _errorMessage = null;
    if (showLoading) notifyListeners();

    try {
      _statuses = await _repository.getApplicationStatuses();
      _allApplications = await _repository.getApplications();
      if (_selectedFilterIndex >= filterTabItems.length) {
        _selectedFilterIndex = 0;
      }
      _applyFilter();
    } catch (e) {
      _errorMessage = AppErrorParser.parse(e);
    } finally {
      if (showLoading) _isLoading = false;
      notifyListeners();
    }
  }

  void setFilterIndex(int index) {
    _selectedFilterIndex = index;
    _applyFilter();
    notifyListeners();
  }

  void _applyFilter() {
    if (_selectedFilterIndex == 0) {
      _filteredApplications = List.from(_allApplications);
      return;
    }

    final selectedTab = filterTabItems[_selectedFilterIndex];
    _filteredApplications = _allApplications.where((app) {
      if (selectedTab.status != null) {
        return app.status == selectedTab.status;
      }

      final normalizedTab = StatusTranslator.normalize(selectedTab.rawValue);
      return StatusTranslator.normalize(app.rawStatusName) == normalizedTab ||
          StatusTranslator.normalize(app.statusName) == normalizedTab ||
          StatusTranslator.normalize(app.displayStatusName) == normalizedTab;
    }).toList();
  }

  /// Returns null on success, or an error message string on failure.
  Future<String?> withdrawApplication(String applicationId) async {
    try {
      await _repository.withdrawApplication(applicationId);
      _markApplicationWithdrawn(applicationId);
      await fetchApplications(showLoading: false);
      return null;
    } catch (e) {
      final message = AppErrorParser.parse(e);
      notifyListeners();
      return message;
    }
  }

  void _markApplicationWithdrawn(String applicationId) {
    _allApplications = _allApplications.map((application) {
      if (application.id != applicationId) return application;
      return application.copyWith(
        status: ApplicationStatus.withdrawn,
        rawStatusName: ApplicationStatus.withdrawn.englishApiValue,
      );
    }).toList();
    _applyFilter();
    notifyListeners();
  }

  String? _extractStatusValue(dynamic status) {
    if (status == null) return null;
    if (status is Map) {
      for (final key in const [
        'name',
        'status',
        'statusName',
        'applicationStatus',
        'value',
        'id',
      ]) {
        final value = status[key];
        if (value != null && value.toString().trim().isNotEmpty) {
          return value.toString();
        }
      }
      return null;
    }

    final value = status.toString().trim();
    return value.isEmpty ? null : value;
  }

  void _addUniqueTab(
    List<ApplicationFilterTab> tabs,
    ApplicationFilterTab tab,
  ) {
    final key = tab.uniqueKey;
    final exists = tabs.any((item) => item.uniqueKey == key);
    if (!exists) tabs.add(tab);
  }
}

class ApplicationFilterTab {
  final String label;
  final ApplicationStatus? status;
  final String rawValue;
  final bool isAll;

  const ApplicationFilterTab({
    required this.label,
    this.status,
    this.rawValue = '',
    this.isAll = false,
  });

  factory ApplicationFilterTab.fromRaw(String rawValue) {
    final status = StatusTranslator.getEnumOrNull(rawValue);
    return ApplicationFilterTab(
      label: StatusTranslator.applicationStatusLabel(rawValue),
      status: status,
      rawValue: rawValue,
    );
  }

  String get uniqueKey {
    if (isAll) return 'all';
    if (status != null) return status!.englishApiValue;
    return StatusTranslator.normalize(label.isNotEmpty ? label : rawValue);
  }
}
