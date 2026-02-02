import 'package:dio/dio.dart';
import 'package:gowork/core/constants/api_constants.dart';
import 'package:gowork/model/auth/register_data_model.dart';

class RegisterRepository {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      headers: {
        'Accept': 'application/json',
        // Do NOT set Content-Type here, let Dio set it to multipart/form-data with boundary
      },
      validateStatus: (status) => status! < 500,
    ),
  );

  Future<void> register(RegisterDataModel data) async {
    final formData = FormData();

    formData.fields
      ..add(MapEntry('firstName', data.firstName))
      ..add(MapEntry('midName', data.fatherName))
      ..add(MapEntry('lastName', data.familyName))
      ..add(MapEntry('email', data.email))
      ..add(MapEntry('phoneNumber', data.phone))
      ..add(MapEntry('Password', data.password))
      ..add(MapEntry('PasswordConfirmation', data.confirmPassword));

    if (data.interstedInCategoryId != null) {
      formData.fields.add(
        MapEntry(
          'interstedInCategoryId',
          data.interstedInCategoryId.toString(),
        ),
      );
    }

    for (final skill in data.skills) {
      formData.fields.add(MapEntry('listOfSkills', skill));
    }

    if (data.profilePhoto != null) {
      formData.files.add(
        MapEntry(
          'ProfilePhoto',
          await MultipartFile.fromFile(data.profilePhoto!.path),
        ),
      );
    }

    if (data.cvFile != null) {
      formData.files.add(
        MapEntry('Resume', await MultipartFile.fromFile(data.cvFile!.path)),
      );
    }

    print('---------------- REGISTRATION DEBUG ----------------');
    for (var field in formData.fields) {
      print('Field: ${field.key} = ${field.value}');
    }
    for (var file in formData.files) {
      print(
        'File: ${file.key} = ${file.value.filename}, path: ${data.profilePhoto?.path}',
      );
    }
    print('----------------------------------------------------');

    try {
      final response = await _dio.post(ApiConstants.register, data: formData);
      print('Response: ${response.statusCode} - ${response.data}');

      if (response.data['success'] != true) {
        final errors = response.data['errors'];
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
