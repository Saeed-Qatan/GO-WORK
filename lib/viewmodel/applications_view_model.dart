import 'package:flutter/material.dart';
import '../model/application_model.dart';
import '../repository/applications_repository.dart';

class ApplicationsViewModel extends ChangeNotifier {
  final ApplicationsRepository _repository = ApplicationsRepository();
  List<ApplicationModel> _allApplications = [];
  List<ApplicationModel> _filteredApplications = [];
  
  List<dynamic> _statuses = [];
  List<String> get filterTabs {
    if (_statuses.isEmpty) {
      return ['الكل', 'Sent', 'PendingReview', 'Accepted', 'Rejected'];
    }
    return ['الكل', ..._statuses.map((s) => s['name']?.toString() ?? s.toString())];
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
    } else {
      final selectedTabName = filterTabs[_selectedFilterIndex];
      _filteredApplications = _allApplications.where((app) {
        // Fallback for hardcoded status enums if api statuses are empty
        if (_statuses.isEmpty) {
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
              case 4:
                targetStatus = ApplicationStatus.rejected;
                break;
              default:
                targetStatus = ApplicationStatus.sent;
            }
            return app.status == targetStatus;
        }
        
        // Dynamic filtering by matching statusName
        return app.statusName.toLowerCase() == selectedTabName.toLowerCase() ||
               app.statusName == selectedTabName;
      }).toList();
    }
  }

  Future<void> withdrawApplication(String applicationId, BuildContext context) async {
    try {
      // show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      await _repository.withdrawApplication(applicationId);
      
      // hide loading indicator
      if (context.mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }
      
      // show success message
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم سحب الطلب بنجاح')),
        );
      }

      // refresh applications
      await fetchApplications();
    } catch (e) {
      // hide loading indicator
      if (context.mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }
      
      // show error message
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فشل سحب الطلب: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
