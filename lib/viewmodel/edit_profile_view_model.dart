import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import '../core/constants/api_constants.dart';
import '../model/edit_profile_model.dart';
import '../model/profile_model.dart';
import '../utils/api_storage.dart';
import '../utils/snackbar_service.dart';
import '../utils/app_error_parser.dart';
import 'profile_view_model.dart';

class EditProfileViewModel extends ChangeNotifier {
  final ProfileViewModel _profileViewModel;
  final ApiClient _apiClient = ApiClient();

  // Controllers
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController middleNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController jobTitleController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController skillController = TextEditingController();

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  EditProfileModel _formData = const EditProfileModel();
  EditProfileModel get formData => _formData;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<Map<String, dynamic>> _categories = [];
  List<Map<String, dynamic>> get categories => _categories;

  bool _isCategoriesLoading = false;
  bool get isCategoriesLoading => _isCategoriesLoading;

  String? _categoriesErrorMessage;
  String? get categoriesErrorMessage => _categoriesErrorMessage;

  String? _selectedCategoryId;
  String? get selectedCategoryId => _selectedCategoryId;
  bool _hasInitializedFromProfile = false;
  bool _isDisposed = false;

  String get cvFileName =>
      _formData.newCvFile != null
          ? _formData.newCvFile!.path.split('/').last
          : (_formData.cvUrl?.isNotEmpty == true
              ? _formData.cvUrl!.split('/').last
              : 'لا يوجد ملف');

  EditProfileViewModel(this._profileViewModel) {
    if (_profileViewModel.profile != null) {
      _initFromProfile(_profileViewModel.profile);
    }
    Future.microtask(() {
      if (!_isDisposed) {
        initializeFromProfile();
        fetchCategories();
      }
    });
  }

  Future<void> initializeFromProfile() async {
    if (_hasInitializedFromProfile) return;

    var profile = _profileViewModel.profile;
    if (profile == null) {
      _isLoading = true;
      if (!_isDisposed) notifyListeners();
      await _profileViewModel.fetchProfile();
      profile = _profileViewModel.profile;
      _isLoading = false;
    }

    _initFromProfile(profile);
    if (!_isDisposed) notifyListeners();
  }

  void _initFromProfile(ProfileModel? profile) {
    if (profile == null) return;
    if (_hasInitializedFromProfile) return;

    firstNameController.text = profile.firstName;
    middleNameController.text = profile.middleName;
    lastNameController.text = profile.lastName;
    jobTitleController.text = profile.jobTitle;
    phoneController.text = profile.phone;
    _selectedCategoryId =
        profile.categoryId.isNotEmpty ? profile.categoryId : null;

    _formData = EditProfileModel(
      firstName: profile.firstName,
      middleName: profile.middleName,
      lastName: profile.lastName,
      jobTitle: profile.jobTitle,
      phone: profile.phone,
      skills: List<String>.from(profile.skills),
      avatarUrl: profile.avatarUrl,
      cvUrl: profile.cvUrl,
    );
    _hasInitializedFromProfile = true;
  }

  Future<void> fetchCategories() async {
    _isCategoriesLoading = true;
    _categoriesErrorMessage = null;
    if (!_isDisposed) notifyListeners();

    try {
      final response = await _apiClient.get(
        ApiConstants.jobCategories,
        skipAuth: true,
      );

      List<dynamic>? categoriesList;
      if (response['data'] is List) {
        categoriesList = response['data'];
      } else if (response['categories'] is List) {
        categoriesList = response['categories'];
      } else if (response['data'] is Map &&
          response['data']['categories'] is List) {
        categoriesList = response['data']['categories'];
      }

      _categories =
          (categoriesList ?? [])
              .map((cat) {
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
              })
              .where(
                (cat) =>
                    cat['id'].toString().trim().isNotEmpty &&
                    cat['name'].toString().trim().isNotEmpty,
              )
              .toList();

      if (_categories.isEmpty) {
        _categoriesErrorMessage =
            'تعذر تحميل المجالات. يمكنك إعادة المحاولة قبل الحفظ.';
      }
    } catch (e) {
      debugPrint('Error fetching profile categories: $e');
      _categories = [];
      _categoriesErrorMessage = AppErrorParser.parse(e);
    } finally {
      _isCategoriesLoading = false;
      if (!_isDisposed) notifyListeners();
    }
  }

  void setCategory(String? id) {
    _selectedCategoryId = id?.trim().isEmpty == true ? null : id;
    if (!_isDisposed) notifyListeners();
  }

  // --- Form Actions ---

  void addSkill() {
    final text = skillController.text.trim();
    if (text.isNotEmpty && !_formData.skills.contains(text)) {
      _formData = _formData.copyWith(skills: [..._formData.skills, text]);
      skillController.clear();
      if (!_isDisposed) notifyListeners();
      SnackbarService.showSuccess('تمت إضافة المهارة');
    } else if (_formData.skills.contains(text)) {
      SnackbarService.showInfo('هذه المهارة مضافة مسبقاً');
    }
  }

  void removeSkill(int index) {
    final updatedSkills = List<String>.from(_formData.skills)..removeAt(index);
    _formData = _formData.copyWith(skills: updatedSkills);
    if (!_isDisposed) notifyListeners();
  }

  Future<void> pickImage() async {
    final ImagePicker picker = ImagePicker();
    try {
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        _formData = _formData.copyWith(newAvatarFile: File(image.path));
        if (!_isDisposed) notifyListeners();
        SnackbarService.showSuccess('تمت إضافة الصورة بنجاح');
      }
    } catch (e) {
      SnackbarService.showError(AppErrorParser.parse(e));
    }
  }

  Future<void> pickCV() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx'],
      );

      if (result?.files.single.path != null) {
        _formData = _formData.copyWith(
          newCvFile: File(result!.files.single.path!),
        );
        if (!_isDisposed) notifyListeners();
        SnackbarService.showSuccess('تم اختيار السيرة الذاتية بنجاح');
      }
    } catch (e) {
      SnackbarService.showError(AppErrorParser.parse(e));
    }
  }

  // --- Submission ---

  Future<bool> saveProfile() async {
    if (!formKey.currentState!.validate()) {
      SnackbarService.showWarning('يرجى التحقق من الحقول الملونة بالأحمر');
      return false;
    }

    final categoryId = _selectedCategoryId?.trim();
    if (categoryId == null || categoryId.isEmpty) {
      SnackbarService.showWarning('يرجى اختيار المجال المناسب');
      return false;
    }

    _isLoading = true;
    if (!_isDisposed) notifyListeners();

    try {
      // Sync controllers back to model just before save
      _formData = _formData.copyWith(
        firstName: firstNameController.text.trim(),
        middleName: middleNameController.text.trim(),
        lastName: lastNameController.text.trim(),
        jobTitle: jobTitleController.text.trim(),
        phone: phoneController.text.trim(),
      );

      // Build form-data fields
      final fields = <String, String>{
        'FirstName': _formData.firstName,
        'MiddleName': _formData.middleName,
        'LastName': _formData.lastName,
        'InterstedInCategoryId': categoryId,
      };

      if (_formData.jobTitle.isNotEmpty) {
        fields['JobTitle'] = _formData.jobTitle;
      }
      if (_formData.phone.isNotEmpty) {
        fields['phoneNo'] = _formData.phone;
      }

      // Skills as repeated form-data fields
      final repeatedFields =
          _formData.skills.map((s) => MapEntry('Skills', s)).toList();

      // Files: ProfilePhoto and Resume
      final files = <String, File>{};
      if (_formData.newAvatarFile != null) {
        files['ProfilePhoto'] = _formData.newAvatarFile!;
      }
      if (_formData.newCvFile != null) {
        files['Resume'] = _formData.newCvFile!;
      }

      // Update profile text data (and try sending files in case backend supports it)
      await _profileViewModel.updateProfile(
        fields: fields,
        repeatedFields: repeatedFields.isEmpty ? null : repeatedFields,
        files: files.isEmpty ? null : files,
      );

      // Upload CV via dedicated endpoint — backend requires field name 'file'
      if (_formData.newCvFile != null) {
        await _profileViewModel.uploadFile(_formData.newCvFile!);
      }

      SnackbarService.showSuccess('تم تحديث الملف الشخصي بنجاح');
      return true;
    } catch (e) {
      SnackbarService.showError(AppErrorParser.parse(e));
      return false;
    } finally {
      _isLoading = false;
      if (!_isDisposed) notifyListeners();
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    firstNameController.dispose();
    middleNameController.dispose();
    lastNameController.dispose();
    jobTitleController.dispose();
    phoneController.dispose();
    skillController.dispose();
    super.dispose();
  }
}
