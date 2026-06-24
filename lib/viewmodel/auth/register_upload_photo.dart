import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:gowork/model/auth/register_data_model.dart';
import 'package:go_router/go_router.dart';
import 'package:gowork/routing/app_router.dart';

class RegisterPhotoViewModel extends ChangeNotifier {
  File? selectedImage;
  bool isLoading = false;

  Future<void> pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowCompression: false,
    );
    if (result?.files.single.path != null) {
      selectedImage = File(result!.files.single.path!);
      notifyListeners();
    }
  }

  void onContinuePressed(BuildContext context, RegisterDataModel base) {
    context.push(
      AppRoutes.registerCV,
      extra: base.copyWith(profilePhoto: selectedImage),
    );
  }

  void onSkipPressed(BuildContext context, RegisterDataModel base) {
    context.push(AppRoutes.registerCV, extra: base);
  }
}
