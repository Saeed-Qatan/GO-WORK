import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:gowork/model/auth/register_data_model.dart';
import 'package:gowork/utils/navigations.dart';

class RegisterPhotoViewModel extends ChangeNotifier {
  File? selectedImage;
  bool isLoading = false;

  Future<void> pickFile(BuildContext context) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
      );
      if (result != null && result.files.single.path != null) {
        selectedImage = File(result.files.single.path!);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
  }

  void removeImage() {
    selectedImage = null;
    notifyListeners();
  }

  Future<void> onContinuePressed(BuildContext context) async {
    isLoading = true;
    notifyListeners();

    try {
      final baseData =
          ModalRoute.of(context)!.settings.arguments as RegisterDataModel;
      final data = baseData.copyWith(profilePhoto: selectedImage);

      Navigator.pushNamed(context, Routes.registerCV, arguments: data);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void onSkipPressed(BuildContext context) {
    final baseData =
        ModalRoute.of(context)!.settings.arguments as RegisterDataModel;
    Navigator.pushNamed(context, Routes.registerCV, arguments: baseData);
  }
}
