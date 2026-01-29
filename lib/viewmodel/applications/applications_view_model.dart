import 'package:flutter/material.dart';
import '../../model/application_model.dart';


class ApplicationsViewModel extends ChangeNotifier {
  List<ApplicationModel> _allApplications = [];
  List<ApplicationModel> _filteredApplications = [];

  List<ApplicationModel> get applications => _filteredApplications;

  int _selectedFilterIndex = 0;
  int get selectedFilterIndex => _selectedFilterIndex;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  ApplicationsViewModel() {
    fetchApplications();
  }

  Future<void> fetchApplications() async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 800)); // Mock API delay

    _allApplications = [
      ApplicationModel(
        id: '1',
        role: 'React Frontend مطور',
        company: 'شركة التقنية المتقدمة',
        companyLogo: '',
        date: '2024-01-15',
        status: ApplicationStatus.inReview,
      ),
      ApplicationModel(
        id: '2',
        role: 'مصمم جرافيك',
        company: 'وكالة الإبداع الرقمي',
        companyLogo: '',
        date: '2024-01-14',
        status: ApplicationStatus.accepted,
      ),
      ApplicationModel(
        id: '3',
        role: 'مختص تسويق رقمي',
        company: 'شركة النمو التسويقي',
        companyLogo: '',
        date: '2024-01-10',
        status: ApplicationStatus.rejected,
      ),
      ApplicationModel(
        id: '4',
        role: 'مطور واجهات',
        company: 'حلول الويب',
        companyLogo: '',
        date: '2024-01-18',
        status: ApplicationStatus.sent,
      ),
    ];

    _applyFilter();
    _isLoading = false;
    notifyListeners();
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
