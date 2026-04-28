import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:gowork/services/profile_service.dart';
import 'package:gowork/model/profile_model.dart';
import 'package:gowork/utils/local_storage.dart';

class ProfileRepository {
  final ProfileService _service = ProfileService();

  /// Fetch the authenticated user's profile from GET /Account/Me
  Future<ProfileModel> getUserProfile() async {
    final response = await _service.getUserProfile();
    // The API may nest data under 'user', 'data', or return it directly
    final data = response['user'] ?? response['data'] ?? response;

    debugPrint('--- RAW PROFILE RESPONSE ---');
    debugPrint(data.toString());

    // Extract email from JWT token if not in the API response
    if ((data['email'] == null || data['email'] == '') &&
        (data['Email'] == null || data['Email'] == '')) {
      final token = await LocalStorage().getString('token');
      if (token != null && token.isNotEmpty) {
        try {
          final parts = token.split('.');
          if (parts.length == 3) {
            final payload = utf8.decode(
              base64Url.decode(base64Url.normalize(parts[1])),
            );
            final payloadMap = json.decode(payload) as Map<String, dynamic>;
            // The email claim key in the JWT
            final email =
                payloadMap['http://schemas.xmlsoap.org/ws/2005/05/identity/claims/emailaddress'] ??
                '';
            data['email'] = email;
          }
        } catch (_) {}
      }
    }

    return ProfileModel.fromJson(data);
  }

  /// Update profile via PATCH /Account/Candidate/UpdateProfile (form-data)
  Future<void> updateProfile({
    required Map<String, String> fields,
    List<MapEntry<String, String>>? repeatedFields,
    Map<String, File>? files,
  }) async {
    await _service.updateProfile(
      fields: fields,
      repeatedFields: repeatedFields,
      files: files,
    );
  }

  /// Get candidate resume from /Account/candidate/me/resume
  Future<dynamic> getResume() async {
    return await _service.getResume();
  }

  /// Upload file via POST /Account/candidate/uploadfile
  Future<void> uploadFile(File file) async {
    await _service.uploadFile(file);
  }
}
