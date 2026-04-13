import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:gowork/model/auth/register_data_model.dart';
import 'package:gowork/services/auth/register_service.dart';
import 'package:gowork/utils/navigations.dart';
import 'package:gowork/utils/snackbar_service.dart';

class RegisterCVViewModel extends ChangeNotifier {
  final skillController = TextEditingController();
  final List<String> _skills = [];
  List<String> get skills => _skills;

  File? cvFile;
  String? cvFileName;

  bool isLoading = false;

  final List<Map<String, String>> categories = [
    {'id': '101', 'name': 'تطوير برمجيات'},
    {'id': '102', 'name': 'البيانات (Data)'},
    {'id': '103', 'name': 'التصميم (Design)'},
    {'id': '104', 'name': 'تطوير تطبيقات الجوال'},
    {'id': '105', 'name': 'المبيعات والتسويق'},
  ];

  String? selectedCategoryId;

  void setCategory(String? id) {
    selectedCategoryId = id;
    notifyListeners();
  }
  final suggestedSkills = [
    'Flutter',
    'Dart',
    'Kotlin',
    'Swift',
    'Java',
    'Python',
    'JavaScript',
    'React',
    'Node.js',
    'SQL',
  ];

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
        categoryId: selectedCategoryId,
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
