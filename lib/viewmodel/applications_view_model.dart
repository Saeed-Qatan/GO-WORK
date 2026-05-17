import 'package:flutter/material.dart';
import '../model/application_model.dart';
import '../repository/applications_repository.dart';
import '../utils/status_translator.dart';

class ApplicationsViewModel extends ChangeNotifier {
  final ApplicationsRepository _repository = ApplicationsRepository();
  List<ApplicationModel> _allApplications = [];
  List<ApplicationModel> _filteredApplications = [];
  List<dynamic> _statuses = [];

  List<String> get filterTabs {
    if (_statuses.isEmpty) {
      return ['الكل', 'Sent', 'PendingReview', 'Accepted', 'Rejected'];
    }

    return [
      'الكل',
      ..._statuses.map((s) => s['name']?.toString() ?? s.toString()),
    ];
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

  Future<void> fetchApplications() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _statuses = await _repository.getApplicationStatuses();
      _allApplications = await _repository.getApplications();
      _applyFilter();
    } catch (e) {
      _errorMessage = 'حدث خطأ أثناء جلب الطلبات: $e';
    } finally {
      _isLoading = false;
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

    final selectedTabName = filterTabs[_selectedFilterIndex];
    final targetStatus = StatusTranslator.getEnum(selectedTabName);
    _filteredApplications = _allApplications.where((app) {
      return app.status == targetStatus ||
          app.statusName.toLowerCase() == selectedTabName.toLowerCase();
    }).toList();
  }

  Future<bool> withdrawApplication(String applicationId) async {
    try {
      await _repository.withdrawApplication(applicationId);
      await fetchApplications();
      return true;
    } catch (e) {
      _errorMessage = 'فشل سحب الطلب: $e';
      notifyListeners();
      return false;
    }
  }
}
