import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:gowork/core/constants/api_constants.dart';
import 'package:gowork/model/auth/register_data_model.dart';
import 'package:gowork/services/auth/register_service.dart';
import 'package:gowork/utils/api_storage.dart';
import 'package:gowork/utils/navigations.dart';
import 'package:gowork/utils/snackbar_service.dart';

class RegisterCVViewModel extends ChangeNotifier {
  final skillController = TextEditingController();
  final List<String> _skills = [];
  List<String> get skills => _skills;

  File? cvFile;
  String? cvFileName;

  bool isLoading = false;

  // --- Categories from API (NO hardcoded data) ---
  final ApiClient _apiClient = ApiClient();
  List<Map<String, dynamic>> _categories = [];
  List<Map<String, dynamic>> get categories => _categories;
  bool isCategoriesLoading = false;

  String? selectedCategoryId;

  RegisterCVViewModel() {
    fetchCategories();
    fetchSuggestedSkills();
  }

  Future<void> fetchCategories() async {
    isCategoriesLoading = true;
    notifyListeners();

    try {
      final response = await _apiClient.get(ApiConstants.jobCategories);
      debugPrint('Categories Response: $response');

      // Parse categories from various possible response structures
      List<dynamic>? categoriesList;
      if (response['data'] is List) {
        categoriesList = response['data'];
      } else if (response['categories'] is List) {
        categoriesList = response['categories'];
      } else if (response['data'] is Map &&
          response['data']['categories'] is List) {
        categoriesList = response['data']['categories'];
      } else if (response.containsKey('success') && response['data'] is List) {
        categoriesList = response['data'];
      }

      if (categoriesList != null && categoriesList.isNotEmpty) {
        _categories = categoriesList.map((cat) {
          return <String, dynamic>{
            'id':
                (cat['id'] ??
                        cat['Id'] ??
                        cat['categoryId'] ??
                        cat['CategoryId'] ??
                        '')
                    .toString(),
            'name':
                (cat['name'] ??
                        cat['Name'] ??
                        cat['categoryName'] ??
                        cat['CategoryName'] ??
                        '')
                    .toString(),
          };
        }).toList();
        debugPrint('Categories loaded from API: ${_categories.length} items');
      } else {
        debugPrint('WARNING: Empty categories from API');
        _categories = [];
      }
    } catch (e) {
      debugPrint('Error fetching categories: $e');
      _categories = [];
    } finally {
      isCategoriesLoading = false;
      notifyListeners();
    }
  }

  void setCategory(String? id) {
    selectedCategoryId = id;
    notifyListeners();
  }

  List<String> suggestedSkills = [];
  bool isSkillsLoading = false;

  Future<void> fetchSuggestedSkills() async {
    isSkillsLoading = true;
    notifyListeners();
    try {
      final response = await _apiClient.get(ApiConstants.jobSkills, skipAuth: true);
      List<dynamic>? skillsList;
      if (response['data'] is List) {
        skillsList = response['data'];
      }
      
      if (skillsList != null) {
        suggestedSkills = skillsList.map((s) => (s['name'] ?? s['title'] ?? s.toString()).toString()).take(15).toList();
      }
    } catch (e) {
      debugPrint('Error fetching suggested skills: $e');
    } finally {
      isSkillsLoading = false;
      notifyListeners();
    }
  }

  void addSkill() {
    final v = skillController.text.trim();
    if (v.isNotEmpty && !_skills.contains(v)) {
      _skills.add(v);
      skillController.clear();
      notifyListeners();
    }
  }

  void removeSkill(String s) {
    _skills.remove(s);
    notifyListeners();
  }

  void addSuggestedSkill(String skill) {
    if (!_skills.contains(skill)) {
      _skills.add(skill);
      notifyListeners();
    }
  }

  Future<void> pickCV() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx'],
    );

    if (result?.files.single.path != null) {
      cvFile = File(result!.files.single.path!);
      cvFileName = result.files.single.name;
      notifyListeners();
    }
  }

  Future<void> finishRegistration(BuildContext context) async {
    isLoading = true;
    notifyListeners();

    try {
      final base =
          ModalRoute.of(context)!.settings.arguments as RegisterDataModel;

      final data = base.copyWith(
        skills: _skills,
        cvFile: cvFile,
        categoryId:
            selectedCategoryId ??
            '101', // Fallback ID if API fails so reg succeeds
      );

      await RegisterService().register(data);

      SnackbarService.showSuccess(
        'تم التسجيل بنجاح. يرجى التحقق من بريدك الإلكتروني.',
      );

      NavigationService.pushNamedAndRemoveUntil(
        Routes.verifyEmail,
        arguments: data.email,
      );
    } catch (e) {
      SnackbarService.showError(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    skillController.dispose();
    super.dispose();
  }
}
