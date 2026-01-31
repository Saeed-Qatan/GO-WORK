import 'package:flutter/material.dart';
import '../model/application_model.dart';
import '../repository/applications_repository.dart';

class ApplicationsViewModel extends ChangeNotifier {
  final ApplicationsRepository _repository = ApplicationsRepository();
  List<ApplicationModel> _allApplications = [];
  List<ApplicationModel> _filteredApplications = [];

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
    } else {
      ApplicationStatus targetStatus;
      switch (_selectedFilterIndex) {
        case 1:
          targetStatus = ApplicationStatus.sent;
          break;
        case 2:
          targetStatus = ApplicationStatus.inReview;
          break;
        case 3:
          targetStatus = ApplicationStatus.accepted;
          break;
        default:
          targetStatus = ApplicationStatus.sent;
      }
      _filteredApplications = _allApplications
          .where((app) => app.status == targetStatus)
          .toList();
    }
  }
}
