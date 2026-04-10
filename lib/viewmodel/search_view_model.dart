import 'package:flutter/material.dart';
import '../model/home_model.dart';
import '../repository/search_repository.dart';

class SearchViewModel extends ChangeNotifier {
  final SearchRepository _repository = SearchRepository();

  List<JobModel> _jobs = [];
  List<JobModel> get jobs => _jobs;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String _searchQuery = '';
  String? _selectedCategory;
  String? _selectedLocation;
  String? _selectedType;
  String? _selectedCountry;

  // Getters for filters
  String? get selectedCategory => _selectedCategory;
  String? get selectedLocation => _selectedLocation;
  String? get selectedType => _selectedType;
  String? get selectedCountry => _selectedCountry;

  String _sortBy = 'date'; // 'date' or 'salary'
  String get sortBy => _sortBy;

  SearchViewModel() {
    searchJobs(); // Load initial data
  }

  void onSearchChanged(String query) {
    _searchQuery = query;
    // Debounce could be added here
    searchJobs();
  }

  void setCategory(String? value) {
    _selectedCategory = value;
    searchJobs();
  }

  void setLocation(String? value) {
    _selectedLocation = value;
    searchJobs();
  }

  void setType(String? value) {
    _selectedType = value;
    searchJobs();
  }

  void setCountry(String? value) {
    _selectedCountry = value;
    searchJobs();
  }

  void setSortBy(String sortBy) {
    _sortBy = sortBy;
    _applySorting();
    notifyListeners();
  }

  void _applySorting() {
    if (_sortBy == 'date') {
      _jobs.sort((a, b) {
        final aDate = DateTime.tryParse(a.postedDate ?? '') ?? DateTime(2000);
        final bDate = DateTime.tryParse(b.postedDate ?? '') ?? DateTime(2000);
        return bDate.compareTo(aDate); // Descending (newest first)
      });
    } else if (_sortBy == 'salary') {
      _jobs.sort((a, b) {
        final aSalary = double.tryParse(a.maxSalary) ?? 0.0;
        final bSalary = double.tryParse(b.maxSalary) ?? 0.0;
        return bSalary.compareTo(aSalary); // Descending (highest salary first)
      });
    }
  }

  Future<void> searchJobs() async {
    _isLoading = true;
    notifyListeners();

    try {
      _jobs = await _repository.searchJobs(
        query: _searchQuery,
        category: _selectedCategory,
        location: _selectedLocation,
        type: _selectedType,
        country: _selectedCountry,
      );
      _applySorting();
    } catch (e) {
      debugPrint('Error searching jobs: $e');
      _jobs = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
