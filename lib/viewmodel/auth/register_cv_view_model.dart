import 'package:flutter/material.dart';
import 'package:gowork/model/auth/register_data_model.dart';
import 'package:gowork/utils/navigations.dart';
import 'package:gowork/view/main_view.dart';
import 'package:provider/provider.dart';
import 'package:gowork/repository/register_repository.dart';

class RegisterCVViewModel extends ChangeNotifier {
  final TextEditingController skillController = TextEditingController();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String _cvFileName = '';
  String get cvFileName => _cvFileName;

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

  Future<void> pickCVFile(BuildContext context) async {
    // TODO: Implement file picker using file_picker package
    // For now, simulate file selection
    _cvFileName = 'my_cv.pdf';

    // TODO: Set cvFile on dataModel when file picker is implemented
    // final dataModel = Provider.of<RegisterDataModel>(context, listen: false);
    // dataModel.setCvFile(pickedFile);

    notifyListeners();
  }

  void addSkillFromTextField(BuildContext context) {
    final skill = skillController.text.trim();
    if (skill.isNotEmpty) {
      final dataModel = Provider.of<RegisterDataModel>(context, listen: false);
      dataModel.addSkill(skill);
      skillController.clear();
      notifyListeners();
    }
  }

  void addSuggestedSkill(BuildContext context, String skill) {
    final dataModel = Provider.of<RegisterDataModel>(context, listen: false);
    dataModel.addSkill(skill);
    notifyListeners();
  }

  void removeSkill(BuildContext context, String skill) {
    final dataModel = Provider.of<RegisterDataModel>(context, listen: false);
    dataModel.removeSkill(skill);
    notifyListeners();
  }

  void selectField(BuildContext context, String? field) {
    if (field != null) {
      final dataModel = Provider.of<RegisterDataModel>(context, listen: false);
      dataModel.setFieldOfInterest(field);
      notifyListeners();
    }
  }

  Future<void> finishRegistration(BuildContext context) async {
    _isLoading = true;
    notifyListeners();

    try {
      final dataModel = Provider.of<RegisterDataModel>(context, listen: false);

      final RegisterRepository repository = RegisterRepository();
      await repository.register(dataModel);

      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('تم التسجيل بنجاح!')));
        NavigationService.pushAndRemoveUntil(const MainView());
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
