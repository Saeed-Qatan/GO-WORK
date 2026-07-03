import 'package:flutter/foundation.dart';
import '../core/constants/api_constants.dart';
import '../model/search/filter_option.dart';
import '../model/home/home_model.dart';
import '../repository/search_repository.dart';
import '../utils/api_storage.dart';
import '../utils/app_error_parser.dart';
import '../utils/status_translator.dart';

/// ✅ الفلترة كلها server-side الآن، مؤكدة بالاختبار المباشر على السيرفر
/// الحقيقي لكل فلتر على حدة:
///   - categoryId          (GET /Jobs/search?categoryId=101 → 39 نتيجة،
///                           كلها "تطوير البرمجيات" فقط)
///   - countryId           (GET /Jobs/search?countryId=122 → تطابق رياضي
///                           100% مع وظائف السعودية)
///   - jobTypeId            (GET /Jobs/search?jobTypeId=1 → FullTime فقط)
///   - jobLocationTypeId    (GET /Jobs/search?jobLocationTypeId=1 → OnSite
///                           فقط — الاسم الحقيقي "JobLocationType" وليس
///                           "LocationType")
/// لا فلترة محلية بعد الآن — السيرفر هو مصدر الحقيقة الوحيد.
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
  List<FilterOption> _categoryOptions = [];
  List<FilterOption> _countryOptions = [];
  List<FilterOption> _locationOptions = [];
  List<FilterOption> _jobTypeOptions = [];

  bool _isCategoriesLoading = false;
  bool _isCountriesLoading = false;
  bool _isLocationTypesLoading = false;
  bool _isJobTypesLoading = false;

  bool get isCategoriesLoading => _isCategoriesLoading;
  bool get isCountriesLoading => _isCountriesLoading;
  bool get isLocationTypesLoading => _isLocationTypesLoading;
  bool get isJobTypesLoading => _isJobTypesLoading;

  List<FilterOption> get categoryOptions => _categoryOptions;
  List<FilterOption> get countryOptions => _countryOptions;
  List<FilterOption> get locationOptions => _locationOptions;
  List<FilterOption> get jobTypeOptions => _jobTypeOptions;

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
        // نحتفظ بالـ id لأنه هو اللي يُرسل للـ backend للفلترة الفعلية،
        // والـ name يُستخدم فقط للعرض بالواجهة.
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
    (data) {
      _categories = data;
      _categoryOptions = _mapOptions(_categories, allCategoriesLabel);
    },
    (v) => _isCategoriesLoading = v,
    skipAuth: true,
  );

  Future<void> _fetchCountries() =>
      _fetchFilterData(ApiConstants.jobCountries, (data) {
        _countries = data;
        _countryOptions = _mapOptions(_countries, allLabel);
      }, (v) => _isCountriesLoading = v);

  Future<void> _fetchLocationTypes() =>
      _fetchFilterData(ApiConstants.locationTypes, (data) {
        _locationTypes = data;
        _locationOptions = _mapOptions(
          _locationTypes,
          allLabel,
          translate: StatusTranslator.workModeLabel,
        );
      }, (v) => _isLocationTypesLoading = v);

  Future<void> _fetchJobTypes() =>
      _fetchFilterData(ApiConstants.jobTypes, (data) {
        _jobTypes = data;
        _jobTypeOptions = _mapOptions(
          _jobTypes,
          allLabel,
          translate: StatusTranslator.jobTypeLabel,
        );
      }, (v) => _isJobTypesLoading = v);

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
      '=== SEARCH VM: query="$_searchQuery", categoryId="${_selectedCategory?.id}", '
      'countryId="${_selectedCountry?.id}", jobLocationTypeId="${_selectedLocation?.id}", '
      'jobTypeId="${_selectedType?.id}" ===',
    );
    notifyListeners();

    try {
      // كل الفلاتر id-based ومؤكدة server-side — بدون أي فلترة محلية.
      final jobs = await _repository.searchJobs(
        query: _searchQuery,
        categoryId: _selectedCategory?.id,
        countryId: _selectedCountry?.id,
        jobLocationTypeId: _selectedLocation?.id,
        jobTypeId: _selectedType?.id,
      );
      if (_isDisposed || requestId != _searchRequestId) return;
      _jobs = jobs;
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

  List<FilterOption> _mapOptions(
    List<Map<String, dynamic>> items,
    String defaultOption, {
    String Function(String value)? translate,
  }) {
    if (items.isEmpty) return [];

    final seen = <String>{};
    final options = <FilterOption>[];
    for (final item in items) {
      final rawId = item['id']?.toString() ?? '';
      final rawName = item['name']?.toString() ?? '';
      if (rawName.trim().isEmpty || rawId.trim().isEmpty) continue;

      final displayName = translate?.call(rawName) ?? rawName;
      final label = displayName.isEmpty ? rawName : displayName;
      if (label == defaultOption) continue;

      if (seen.add(rawId)) {
        options.add(FilterOption(label: label, rawValue: rawName, id: rawId));
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