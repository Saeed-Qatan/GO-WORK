import 'package:flutter/material.dart';
import '../model/home_model.dart';
import '../repository/home_repository.dart';

class HomeViewModel extends ChangeNotifier {
  final HomeRepository _repository = HomeRepository();

  List<StatModel> _stats = [];
  List<StatModel> get stats => _stats;

  List<JobModel> _jobs = [];
  List<JobModel> get jobs => _jobs;

  String _userName = '';
  String get userName => _userName;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  int _selectedIndex = 0; // 0 is Home
  int get selectedIndex => _selectedIndex;

  Future<void> fetchHomeData() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Fetch in parallel
      final results = await Future.wait([
        _repository.getStats(),
        _repository.getRecommendedJobs(),
        _repository.getUserName(),
      ]);

      _stats = results[0] as List<StatModel>;
      _jobs = results[1] as List<JobModel>;
      _userName = results[2] as String;
    } catch (e) {
      debugPrint('Error fetching home data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setTabIndex(int index) {
    _selectedIndex = index;
    notifyListeners();
  }
}
