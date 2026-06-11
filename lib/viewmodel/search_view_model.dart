import 'package:flutter/foundation.dart';
import '../core/constants/api_constants.dart';
import '../model/search/filter_option.dart';
import '../model/home/home_model.dart';
import '../repository/search_repository.dart';
import '../utils/api_storage.dart';
import '../utils/app_error_parser.dart';
import '../utils/status_translator.dart';

class SearchViewModel extends ChangeNotifier {
  static const String allLabel = 'الكل';
  static const String allCategoriesLabel = 'جميع المجالات';

  final SearchRepository _repository = SearchRepository();
  final ApiClient _apiClient = ApiClient();
  bool _isDisposed = false;

  List<JobModel> _jobs = [];
  List<JobModel> get jobs => _jobs;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

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

  List<FilterOption> get categoryOptions =>
      _mapOptions(_categories, allCategoriesLabel);
  List<FilterOption> get countryOptions => _mapOptions(_countries, allLabel);
  List<FilterOption> get locationOptions => _mapOptions(
    _locationTypes,
    allLabel,
    translate: StatusTranslator.workModeLabel,
  );
  List<FilterOption> get jobTypeOptions => _mapOptions(
    _jobTypes,
    allLabel,
    translate: StatusTranslator.jobTypeLabel,
  );

  String _searchQuery = '';
  FilterOption? _selectedCategory;
  FilterOption? _selectedLocation;
  FilterOption? _selectedType;
  FilterOption? _selectedCountry;
  int _searchRequestId = 0;

  FilterOption? get selectedCategory => _selectedCategory;
  FilterOption? get selectedLocation => _selectedLocation;
  FilterOption? get selectedType => _selectedType;
  FilterOption? get selectedCountry => _selectedCountry;

  String _sortBy = 'date';
  String get sortBy => _sortBy;

  SearchViewModel() {
    _fetchAllFilters();
    searchJobs();
  }

  Future<void> _fetchAllFilters() async {
    _fetchCategories();
    _fetchCountries();
    _fetchLocationTypes();
    _fetchJobTypes();
  }

  Future<void> _fetchFilterData(
    String endpoint,
    void Function(List<Map<String, dynamic>>) onSuccess,
    void Function(bool) setLoading, {
    bool skipAuth = false,
  }) async {
    if (_isDisposed) return;
    setLoading(true);
    if (!_isDisposed) notifyListeners();

    try {
      final response = await _apiClient.get(endpoint, skipAuth: skipAuth);
      List<dynamic>? list;

      if (response['data'] is List) {
        list = response['data'] as List<dynamic>;
      } else if (response.containsKey('success') && response['data'] is List) {
        list = response['data'] as List<dynamic>;
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
    searchJobs();
  }

  void setCategory(FilterOption? value) {
    _selectedCategory = value;
    searchJobs();
  }

  void setLocation(FilterOption? value) {
    _selectedLocation = value;
    searchJobs();
  }

  void setType(FilterOption? value) {
    _selectedType = value;
    searchJobs();
  }

  void setCountry(FilterOption? value) {
    _selectedCountry = value;
    searchJobs();
  }

  void setSortBy(String sortBy) {
    _sortBy = sortBy;
    _applySorting();
    if (!_isDisposed) notifyListeners();
  }

  Future<void> searchJobs() async {
    if (_isDisposed) return;
    final requestId = ++_searchRequestId;
    _isLoading = true;
    _errorMessage = null;
    _debugLog('=== SEARCH VM: searchJobs start ===');
    _debugLog(
      '=== SEARCH VM: query="$_searchQuery", category="${_selectedCategory?.rawValue}", locationType="${_selectedLocation?.rawValue}", jobType="${_selectedType?.rawValue}", country="${_selectedCountry?.rawValue}" ===',
    );
    notifyListeners();

    try {
      final jobs = await _repository.searchJobs(
        query: _searchQuery,
        category: _selectedCategory?.rawValue,
        workMode: _selectedLocation?.rawValue,
        type: _selectedType?.rawValue,
        country: _selectedCountry?.rawValue,
      );
      if (_isDisposed || requestId != _searchRequestId) return;
      _jobs = _applyClientFilters(jobs);
      _applySorting();
      _debugLog('=== SEARCH VM: jobs loaded=${_jobs.length} ===');
    } catch (e) {
      if (_isDisposed || requestId != _searchRequestId) return;
      _errorMessage = AppErrorParser.parse(e);
      _debugLog(
        '=== SEARCH VM ERROR (${e.runtimeType}): $e | parsed=$_errorMessage ===',
      );
      _jobs = [];
    } finally {
      // Avoid updating UI for stale / superseded requests.
      if (!_isDisposed && requestId == _searchRequestId) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  void _applySorting() {
    if (_sortBy == 'date') {
      _jobs.sort((a, b) {
        final aDate = DateTime.tryParse(a.postedDate ?? '') ?? DateTime(2000);
        final bDate = DateTime.tryParse(b.postedDate ?? '') ?? DateTime(2000);
        return bDate.compareTo(aDate);
      });
    } else if (_sortBy == 'salary') {
      _jobs.sort((a, b) {
        final aSalary = double.tryParse(a.maxSalary) ?? 0.0;
        final bSalary = double.tryParse(b.maxSalary) ?? 0.0;
        return bSalary.compareTo(aSalary);
      });
    }
  }

  List<JobModel> _applyClientFilters(List<JobModel> jobs) {
    final selectedCategory = _selectedCategory;
    final selectedCountry = _selectedCountry;
    final selectedLocation = _selectedLocation;
    final selectedType = _selectedType;
    // Client-side text fallback: ensures visible results change when typing,
    // even when the backend ignores the `query` parameter or lags behind.
    final query = _searchQuery.trim().toLowerCase();

    return jobs.where((job) {
      // ── Text search (client-side fallback) ──────────────────────────────
      if (query.isNotEmpty) {
        final matchesText = job.title.toLowerCase().contains(query) ||
            job.company.toLowerCase().contains(query) ||
            job.category.toLowerCase().contains(query) ||
            job.location.toLowerCase().contains(query);
        if (!matchesText) return false;
      }

      // ── Dropdown filters ─────────────────────────────────────────────────
      if (selectedCategory != null &&
          !_matchesText(job.category, selectedCategory.rawValue)) {
        return false;
      }

      if (selectedCountry != null &&
          !_matchesText(job.country, selectedCountry.rawValue)) {
        return false;
      }

      if (selectedLocation != null &&
          !_matchesWorkMode(job, selectedLocation)) {
        return false;
      }

      if (selectedType != null && !_matchesJobType(job, selectedType)) {
        return false;
      }

      return true;
    }).toList();
  }

  bool _matchesWorkMode(JobModel job, FilterOption selectedLocation) {
    final selectedRaw = selectedLocation.rawValue?.trim();
    if (selectedRaw == null || selectedRaw.isEmpty) return true;

    final jobRaw = job.workMode.trim();
    if (jobRaw.isEmpty) return false;

    if (StatusTranslator.normalize(jobRaw) ==
        StatusTranslator.normalize(selectedRaw)) {
      return true;
    }

    final selectedLabel = StatusTranslator.workModeLabel(selectedRaw);
    final jobLabel = StatusTranslator.workModeLabel(jobRaw);
    if (selectedLabel.trim().isEmpty || jobLabel.trim().isEmpty) return false;

    return StatusTranslator.normalize(selectedLabel) ==
        StatusTranslator.normalize(jobLabel);
  }

  bool _matchesJobType(JobModel job, FilterOption selectedType) {
    final selectedRaw = selectedType.rawValue?.trim();
    if (selectedRaw == null || selectedRaw.isEmpty) return true;

    final jobRaw = job.type.trim();
    if (jobRaw.isEmpty) return false;

    if (StatusTranslator.normalize(jobRaw) ==
        StatusTranslator.normalize(selectedRaw)) {
      return true;
    }

    final selectedLabel = StatusTranslator.jobTypeLabel(selectedRaw);
    final jobLabel = StatusTranslator.jobTypeLabel(jobRaw);
    if (selectedLabel.trim().isEmpty || jobLabel.trim().isEmpty) return false;

    return StatusTranslator.normalize(selectedLabel) ==
        StatusTranslator.normalize(jobLabel);
  }

  bool _matchesText(String jobValue, String? selectedValue) {
    final selectedRaw = selectedValue?.trim();
    if (selectedRaw == null || selectedRaw.isEmpty) return true;

    final jobRaw = jobValue.trim();
    if (jobRaw.isEmpty) return false;

    return StatusTranslator.normalize(jobRaw) ==
        StatusTranslator.normalize(selectedRaw);
  }

  List<FilterOption> _mapOptions(
    List<Map<String, dynamic>> items,
    String defaultOption, {
    String Function(String value)? translate,
  }) {
    if (items.isEmpty) return [];

    final seen = <String>{};
    final options = <FilterOption>[];
    for (final item in items) {
      final rawName = item['name']?.toString() ?? '';
      if (rawName.trim().isEmpty) continue;

      final displayName = translate?.call(rawName) ?? rawName;
      final label = displayName.isEmpty ? rawName : displayName;
      if (label == defaultOption) continue;

      final key = '${label.trim()}|${rawName.trim()}';
      if (seen.add(key)) {
        options.add(FilterOption(label: label, rawValue: rawName));
      }
    }

    return options;
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  void _debugLog(String message) {
    if (kDebugMode) {
      debugPrint(message);
    }
  }
}
