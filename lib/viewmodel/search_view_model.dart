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

  // Getters for filters
  String? get selectedCategory => _selectedCategory;
  String? get selectedLocation => _selectedLocation;
  String? get selectedType => _selectedType;

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

  Future<void> searchJobs() async {
    _isLoading = true;
    notifyListeners();

    try {
      _jobs = await _repository.searchJobs(
        query: _searchQuery,
        category: _selectedCategory,
        location: _selectedLocation,
        type: _selectedType,
      );
    } catch (e) {
      debugPrint('Error searching jobs: $e');
      _jobs = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
