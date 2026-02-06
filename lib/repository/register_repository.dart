import 'dart:io';

import 'package:gowork/core/constants/api_constants.dart';
import 'package:gowork/model/auth/register_data_model.dart';
import 'package:gowork/utils/api_storage.dart';

class RegisterRepository {
  final ApiClient _apiClient = ApiClient();

  Future<void> register(RegisterDataModel data) async {
    final Map<String, String> fields = {
      'firstName': data.firstName,
      'midName': data.fatherName,
      'lastName': data.familyName,
      'email': data.email,
      'phoneNumber': data.phone,
      'Password': data.password,
      'PasswordConfirmation': data.confirmPassword,
    };

    if (data.interstedInCategoryId != null) {
      fields['interstedInCategoryId'] = data.interstedInCategoryId.toString();
    }

    final List<MapEntry<String, String>> repeatedFields = [];
    for (final skill in data.skills) {
      repeatedFields.add(MapEntry('listOfSkills', skill));
    }

    final Map<String, File> files = {};
    if (data.profilePhoto != null) {
      files['ProfilePhoto'] = data.profilePhoto!;
    }
    if (data.cvFile != null) {
      files['Resume'] = data.cvFile!;
    }

    try {
      final response = await _apiClient.postMultipart(
        ApiConstants.register,
        fields: fields,
        repeatedFields: repeatedFields,
        files: files,
      );

      print('Response: $response');

      if (response['success'] != true) {
        final errors = response['errors'];
        String errorMessage = 'Registration failed';
        if (errors is List && errors.isNotEmpty) {
          errorMessage = errors.join('\n');
        } else if (errors is Map) {
          errorMessage = errors.values.join('\n');
        } else if (errors is String) {
          errorMessage = errors;
        }
        throw Exception(errorMessage);
      }
    } catch (e) {
      print('Registration Exception: $e');
      rethrow;
    }
  }
}
