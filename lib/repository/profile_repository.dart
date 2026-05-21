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

    final jwtPayload = await _readJwtPayload();

    // Extract email from JWT token if not in the API response
    if ((data['email'] == null || data['email'] == '') &&
        (data['Email'] == null || data['Email'] == '')) {
      if (jwtPayload != null) {
        final email =
            jwtPayload['http://schemas.xmlsoap.org/ws/2005/05/identity/claims/emailaddress'] ??
            '';
        data['email'] = email;
      }
    }

    final jwtCategoryId = _readCategoryIdFromJwt(jwtPayload);
    if (jwtCategoryId.isNotEmpty &&
        ProfileModel.fromJson(data).categoryId.isEmpty) {
      data['categoryId'] = jwtCategoryId;
    }

    final profile = ProfileModel.fromJson(data);
    debugPrint(
      '=== PROFILE REPOSITORY DEBUG: CATEGORY ID = ${profile.categoryId.isNotEmpty ? profile.categoryId : 'EMPTY'} ===',
    );
    if (profile.categoryId.isNotEmpty) {
      await LocalStorage().saveString('categoryId', profile.categoryId);
    }

    return profile;
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

  Future<Map<String, dynamic>?> _readJwtPayload() async {
    final token = await LocalStorage().getString('token');
    if (token == null || token.isEmpty) return null;

    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;

      final payload = utf8.decode(
        base64Url.decode(base64Url.normalize(parts[1])),
      );
      final decoded = json.decode(payload);
      if (decoded is! Map<String, dynamic>) return null;

      final categoryClaimKeys = decoded.keys
          .where((key) => key.toLowerCase().contains('category'))
          .toList();
      debugPrint(
        '=== JWT DEBUG: CATEGORY CLAIM KEYS = ${categoryClaimKeys.isEmpty ? 'NONE' : categoryClaimKeys.join(', ')} ===',
      );

      return decoded;
    } catch (e) {
      debugPrint('=== JWT DEBUG: PAYLOAD READ ERROR: $e ===');
      return null;
    }
  }

  String _readCategoryIdFromJwt(Map<String, dynamic>? payload) {
    if (payload == null) return '';

    for (final key in const [
      'categoryId',
      'CategoryId',
      'interstedInCategoryId',
      'InterstedInCategoryId',
      'interestedInCategoryId',
      'InterestedInCategoryId',
      'interestedCategoryId',
      'InterestedCategoryId',
      'jobCategoryId',
      'JobCategoryId',
    ]) {
      final value = payload[key];
      if (value != null && value.toString().trim().isNotEmpty) {
        return value.toString();
      }
    }

    for (final entry in payload.entries) {
      if (!entry.key.toLowerCase().contains('category')) continue;
      final value = entry.value;
      if (value != null && value.toString().trim().isNotEmpty) {
        return value.toString();
      }
    }

    return '';
  }
}
