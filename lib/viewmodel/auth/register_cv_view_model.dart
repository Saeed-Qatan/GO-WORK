import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:gowork/model/auth/register_data_model.dart';
import 'package:gowork/utils/navigations.dart';
import 'package:gowork/services/auth/register_service.dart';

class RegisterCVViewModel extends ChangeNotifier {
  final TextEditingController skillController = TextEditingController();
  final List<String> _skills = [];
  List<String> get skills => List.unmodifiable(_skills);

  String? _selectedField;
  String? get selectedField => _selectedField;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  File? _cvFile;
  File? get cvFile => _cvFile;
  String? _cvFileName;
  String? get cvFileName => _cvFileName;

  final List<String> suggestedSkills = [
    'JavaScript',
    'Python',
    'React',
    'Node.js',
    'HTML/CSS',
    'Flutter',
    'تحليل البيانات',
    'إدارة المشاريع',
    'التسويق الرقمي',
    'التصميم الجرافيكي',
  ];

  final List<String> fieldsOfInterest = [
    'تطوير البرمجيات',
    'تحليل البيانات',
    'التسويق الرقمي',
    'إدارة المشاريع',
    'التصميم الجرافيكي',
    'الموارد البشرية',
    'المحاسبة والمالية',
    'الذكاء الاصطناعي',
  ];

  void addSkillFromTextField() {
    final skill = skillController.text.trim();
    if (skill.isNotEmpty && !_skills.contains(skill)) {
      _skills.add(skill);
      skillController.clear();
      notifyListeners();
    }
  }

  void addSuggestedSkill(String skill) {
    if (!_skills.contains(skill)) {
      _skills.add(skill);
      notifyListeners();
    }
  }

  void removeSkill(String skill) {
    _skills.remove(skill);
    notifyListeners();
  }

  void selectField(String? field) {
    _selectedField = field;
    notifyListeners();
  }

  Future<void> pickCVFile(BuildContext context) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx'],
      );

      if (result != null && result.files.single.path != null) {
        _cvFile = File(result.files.single.path!);
        _cvFileName = result.files.single.name;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error picking CV: $e');
    }
  }

  Future<void> finishRegistration(BuildContext context) async {
    _isLoading = true;
    notifyListeners();

    try {
      final baseDataModel =
          ModalRoute.of(context)!.settings.arguments as RegisterDataModel;

      final completeDataModel = baseDataModel.copyWith(
        skills: _skills,
        interstedInCategoryId: _selectedField != null
            ? fieldsOfInterest.indexOf(_selectedField!) + 1
            : null,
        cvFile: _cvFile,
      );

      final RegisterService service = RegisterService();
      await service.register(completeDataModel);

      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('تم التسجيل بنجاح!')));
        NavigationService.pushNamedAndRemoveUntil(Routes.login);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('حدث خطأ: ${e.toString()}')));
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    skillController.dispose();
    super.dispose();
  }
}
