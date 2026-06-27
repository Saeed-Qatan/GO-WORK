import 'dart:io';
import 'package:gowork/utils/api_storage.dart';
import 'package:gowork/core/constants/api_constants.dart';

class ProfileService {
  final ApiClient _apiClient = ApiClient();

  /// GET /Account/Me — fetch the authenticated user's profile
  Future<Map<String, dynamic>> getUserProfile() async {
    return await _apiClient.get(ApiConstants.getProfile);
  }

  /// GET /Account/candidate/me/resume — fetch signed resume URL
  /// Returns: { statusCode, success, data: { sasUrl, expiresAt, succeeded }, errors }
  Future<Map<String, dynamic>> getResume() async {
    return await _apiClient.get(ApiConstants.getResume);
  }

  /// POST /Account/candidate/uploadfile — upload file (resume or photo)
  Future<Map<String, dynamic>> uploadFile(File file) async {
    return await _apiClient.postMultipart(
      ApiConstants.uploadFile,
      files: {'file': file},
    );
  }

  /// PATCH /Account/Candidate/UpdateProfile — update profile (form-data)
  /// Sends text fields, repeated skills, ProfilePhoto, and ResumeFile
  /// all in a single multipart PATCH request.
  Future<Map<String, dynamic>> updateProfile({
    required Map<String, String> fields,
    List<MapEntry<String, String>>? repeatedFields,
    Map<String, File>? files,
  }) async {
    return await _apiClient.patchMultipart(
      ApiConstants.updateProfile,
      fields: fields,
      repeatedFields: repeatedFields,
      files: files,
    );
  }
}
