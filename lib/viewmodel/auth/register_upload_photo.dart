import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:gowork/model/auth/register_data_model.dart';
import 'package:gowork/utils/navigations.dart';

class RegisterPhotoViewModel extends ChangeNotifier {
  File? selectedImage;
  bool isLoading = false;

  Future<void> pickFile() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result?.files.single.path != null) {
      selectedImage = File(result!.files.single.path!);
      notifyListeners();
    }
  }

  void onContinuePressed(BuildContext context) {
    final base =
        ModalRoute.of(context)!.settings.arguments as RegisterDataModel;

    Navigator.pushNamed(
      context,
      Routes.registerCV,
      arguments: base.copyWith(profilePhoto: selectedImage),
    );
  }

  void onSkipPressed(BuildContext context) {
    final base =
        ModalRoute.of(context)!.settings.arguments as RegisterDataModel;

    Navigator.pushNamed(context, Routes.registerCV, arguments: base);
  }
}
