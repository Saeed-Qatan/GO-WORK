import 'dart:io';

import 'package:flutter/foundation.dart';
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
      // Use dynamic category ID, fallback to '101' if somehow null
      'InterstedInCategoryId': data.categoryId ?? '101',
    };

    final repeatedFields = data.skills
        .map((skill) => MapEntry('listOfSkills', skill))
        .toList();

    final Map<String, File> files = {};
    if (data.profilePhoto != null) {
      files['ProfilePhoto'] = data.profilePhoto!;
    }
    if (data.cvFile != null) {
      files['Resume'] = data.cvFile!;
    }

    // Debug: Log everything being sent
    debugPrint('=== REGISTER REQUEST DEBUG ===');
    debugPrint('Endpoint: ${ApiConstants.register}');
    fields.forEach((k, v) => debugPrint('  Field: $k = $v'));
    for (final entry in repeatedFields) {
      debugPrint('  Repeated: ${entry.key} = ${entry.value}');
    }
    files.forEach((k, v) => debugPrint('  File: $k = ${v.path}'));
    debugPrint('=== END DEBUG ===');

    try {
      final response = await _apiClient.postMultipart(
        ApiConstants.register,
        fields: fields,
        repeatedFields: repeatedFields,
        files: files,
        skipAuth: true,
      );

      debugPrint('Register Response: $response');

      if (response['success'] != true) {
        final errors = response['errors'];
        String errorMessage = 'فشل التسجيل';
        if (errors is List && errors.isNotEmpty) {
          errorMessage = errors.join('\n');
        } else if (errors is Map) {
          errorMessage = errors.values
              .expand((v) => v is List ? v : [v])
              .join('\n');
        } else if (errors is String) {
          errorMessage = errors;
        }
        throw Exception(errorMessage);
      }
    } catch (e) {
      debugPrint('Registration Exception: $e');
      // Extract better error from DioException response if available
      final errStr = e.toString();
      if (errStr.contains('errors')) {
        // Try to extract meaningful error from the server response
        final emailDup = errStr.contains('email') || errStr.contains('Email');
        final phoneDup = errStr.contains('phone') || errStr.contains('Phone');
        if (emailDup) {
          throw Exception(
            'البريد الإلكتروني مسجل مسبقاً. يرجى استخدام بريد آخر.',
          );
        }
        if (phoneDup) {
          throw Exception('رقم الهاتف مسجل مسبقاً. يرجى استخدام رقم آخر.');
        }
      }
      rethrow;
    }
  }
}
