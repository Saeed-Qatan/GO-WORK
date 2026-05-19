import 'package:flutter/material.dart';
import '../model/home_model.dart';
import '../repository/search_repository.dart';
import '../utils/api_storage.dart';
import '../core/constants/api_constants.dart';

class SearchViewModel extends ChangeNotifier {
  final SearchRepository _repository = SearchRepository();
  bool _isDisposed = false;

  List<JobModel> _jobs = [];
  List<JobModel> get jobs => _jobs;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  final ApiClient _apiClient = ApiClient();

  // Dynamic Lists for Filters
  List<Map<String, dynamic>> _categories = [];
  List<Map<String, dynamic>> _countries = [];
  List<Map<String, dynamic>> _locationTypes = [];
  List<Map<String, dynamic>> _jobTypes = [];

  bool _isCategoriesLoading = false;
  bool _isCountriesLoading = false;
  bool _isLocationTypesLoading = false;
  bool _isJobTypesLoading = false;

  bool get isCategoriesLoading => _isCategoriesLoading;
  bool get isCountriesLoading => _isCountriesLoading;
  bool get isLocationTypesLoading => _isLocationTypesLoading;
  bool get isJobTypesLoading => _isJobTypesLoading;

  List<String> get categoryNames => _mapNames(_categories, 'جميع المجالات');
  List<String> get countryNames => _mapNames(_countries, 'الكل');
  List<String> get locationNames => _mapNames(_locationTypes, 'الكل');
  List<String> get jobTypeNames => _mapNames(_jobTypes, 'الكل');

  List<String> _mapNames(
    List<Map<String, dynamic>> items,
    String defaultOption,
  ) {
    if (items.isEmpty) return [defaultOption];
    final names = items.map((e) => e['name'].toString()).toSet().toList();
    names.remove(
      defaultOption,
    ); // Remove if API already returns it, to avoid duplicates
    return [defaultOption, ...names];
  }

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
    _fetchAllFilters();
    searchJobs(); // Load initial data
  }

  Future<void> _fetchAllFilters() async {
    _fetchCategories();
    _fetchCountries();
    _fetchLocationTypes();
    _fetchJobTypes();
  }

  Future<void> _fetchFilterData(
    String endpoint,
    Function(List<Map<String, dynamic>>) onSuccess,
    Function(bool) setLoading, {
    bool skipAuth = false,
  }) async {
    if (_isDisposed) return;
    setLoading(true);
    if (!_isDisposed) notifyListeners();

    try {
      final response = await _apiClient.get(endpoint, skipAuth: skipAuth);
      List<dynamic>? list;

      if (response['data'] is List) {
        list = response['data'];
      } else if (response.containsKey('success') && response['data'] is List) {
        list = response['data'];
      }

      if (list != null && list.isNotEmpty) {
        final parsed = list.map((item) {
          return <String, dynamic>{
            'id': (item['id'] ?? item['Id'] ?? item['code'] ?? '').toString(),
            'name':
                (item['name'] ??
                        item['Name'] ??
                        item['title'] ??
                        item['Title'] ??
                        '')
                    .toString(),
          };
        }).toList();
        onSuccess(parsed);
      } else {
        onSuccess([]);
      }
    } catch (e) {
      debugPrint('Error fetching filter data ($endpoint): $e');
      onSuccess([]);
    } finally {
      setLoading(false);
      if (!_isDisposed) notifyListeners();
    }
  }

  Future<void> _fetchCategories() => _fetchFilterData(
    ApiConstants.jobCategories,
    (data) => _categories = data,
    (v) => _isCategoriesLoading = v,
    skipAuth: true,
  );
  Future<void> _fetchCountries() => _fetchFilterData(
    ApiConstants.jobCountries,
    (data) => _countries = data,
    (v) => _isCountriesLoading = v,
  );
  Future<void> _fetchLocationTypes() => _fetchFilterData(
    ApiConstants.locationTypes,
    (data) => _locationTypes = data,
    (v) => _isLocationTypesLoading = v,
  );
  Future<void> _fetchJobTypes() => _fetchFilterData(
    ApiConstants.jobTypes,
    (data) => _jobTypes = data,
    (v) => _isJobTypesLoading = v,
  );

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
    if (!_isDisposed) notifyListeners();
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
    if (_isDisposed) return;
    _isLoading = true;
    notifyListeners();

    try {
      _jobs = await _repository.searchJobs(
        query: _searchQuery,
        category: _selectedCategory,
        workMode: _selectedLocation,
        type: _selectedType,
        country: _selectedCountry,
      );
      _applySorting();
    } catch (e) {
      debugPrint('Error searching jobs: $e');
      _jobs = [];
    } finally {
      _isLoading = false;
      if (!_isDisposed) {
        notifyListeners();
      }
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }
}
