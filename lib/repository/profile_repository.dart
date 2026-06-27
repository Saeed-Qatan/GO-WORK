import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:gowork/services/profile_service.dart';
import 'package:gowork/model/profile_model.dart';
import 'package:gowork/utils/local_storage.dart';
import 'package:gowork/utils/api_storage.dart';
import 'package:gowork/core/constants/api_constants.dart';

class ProfileRepository {
  final ProfileService _service = ProfileService();

  /// Fetch the authenticated user's profile from GET /Account/Me
  Future<ProfileModel> getUserProfile() async {
    final response = await _service.getUserProfile();
    // The API may nest data under 'user', 'data', or return it directly
    final data = response['user'] ?? response['data'] ?? response;

    debugPrint('--- RAW PROFILE RESPONSE ---');
    debugPrint(response.toString());

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

    // --- categoryId resolution (priority order) ---
    // 1. Try the extracted data map (the primary response body).
    // 2. Try every nested Map in the full raw response (catches sibling keys).
    // 3. Try the JWT token claims.
    // 4. Fall back to LocalStorage (survives logout but not app reinstall).

    if (ProfileModel.fromJson(data).categoryId.isEmpty) {
      // Search the full raw response for categoryId at any nesting level
      final responseId = _searchCategoryIdInResponse(response);
      if (responseId.isNotEmpty) {
        data['categoryId'] = responseId;
        debugPrint(
          '=== PROFILE REPOSITORY: FOUND CATEGORY ID IN FULL RESPONSE: $responseId ===',
        );
      }
    }

    final jwtCategoryId = _readCategoryIdFromJwt(jwtPayload);
    if (jwtCategoryId.isNotEmpty &&
        ProfileModel.fromJson(data).categoryId.isEmpty) {
      data['categoryId'] = jwtCategoryId;
      debugPrint(
        '=== PROFILE REPOSITORY: FOUND CATEGORY ID IN JWT: $jwtCategoryId ===',
      );
    }

    final storage = LocalStorage();

    // Fallback: if API and JWT both returned no categoryId, use the value
    // cached for the same authenticated user.
    // NOTE: This cache is wiped on app reinstall — it is the last resort only.
    if (ProfileModel.fromJson(data).categoryId.isEmpty) {
      final cachedCategoryId = await storage.getScopedString('categoryId');
      if (cachedCategoryId != null && cachedCategoryId.trim().isNotEmpty) {
        data['categoryId'] = cachedCategoryId;
        debugPrint(
          '=== PROFILE REPOSITORY: RESTORED CATEGORY ID FROM LOCAL CACHE: $cachedCategoryId ===',
        );
      }
    }

    var profile = ProfileModel.fromJson(data);

    // If categoryId is empty but categoryName is present, resolve it from the categories API list.
    if (profile.categoryId.isEmpty && profile.categoryName.isNotEmpty) {
      try {
        final client = ApiClient();
        final catResponse = await client.get(
          ApiConstants.jobCategories,
          skipAuth: true,
        );

        List<dynamic>? categoriesList;
        if (catResponse['data'] is List) {
          categoriesList = catResponse['data'];
        } else if (catResponse['categories'] is List) {
          categoriesList = catResponse['categories'];
        } else if (catResponse['data'] is Map &&
            catResponse['data']['categories'] is List) {
          categoriesList = catResponse['data']['categories'];
        }

        if (categoriesList != null) {
          for (final cat in categoriesList) {
            final id = (cat['id'] ??
                        cat['Id'] ??
                        cat['categoryId'] ??
                        cat['CategoryId'] ??
                        '')
                    .toString().trim();
            final name = (cat['name'] ??
                          cat['Name'] ??
                          cat['categoryName'] ??
                          cat['CategoryName'] ??
                          '')
                    .toString().trim();
            if (name.toLowerCase() == profile.categoryName.toLowerCase() && id.isNotEmpty) {
              profile = profile.copyWith(categoryId: id);
              debugPrint(
                '=== PROFILE REPOSITORY: RESOLVED CATEGORY ID from NAME "$name" -> "$id" ===',
              );
              break;
            }
          }
        }
      } catch (e) {
        debugPrint('=== PROFILE REPOSITORY: Error resolving category ID from name: $e ===');
      }
    }

    debugPrint(
      '=== PROFILE REPOSITORY DEBUG: CATEGORY ID = ${profile.categoryId.isNotEmpty ? profile.categoryId : 'EMPTY'} ===',
    );
    if (profile.categoryId.isNotEmpty) {
      await storage.saveScopedString('categoryId', profile.categoryId);
    }

    return profile;
  }

  /// Searches the full API response map at every nesting level for a categoryId.
  /// This handles cases where the backend nests the ID under a sibling key
  /// to 'user'/'data' (e.g. response['candidate']['interstedInCategoryId']).
  String _searchCategoryIdInResponse(Map<String, dynamic> response) {
    // First pass: flat keys on every map we encounter using BFS
    final queue = <Map<String, dynamic>>[response];
    final visited = <Map<String, dynamic>>{};

    while (queue.isNotEmpty) {
      final current = queue.removeAt(0);
      if (!visited.add(current)) continue;

      // Try all known categoryId key names on the current map
      final id = ProfileModel.readCategoryIdFromMap(current);
      if (id.isNotEmpty) return id;

      // Enqueue nested Map values for the next BFS pass
      for (final value in current.values) {
        if (value is Map<String, dynamic>) {
          queue.add(value);
        } else if (value is List) {
          for (final item in value) {
            if (item is Map<String, dynamic>) {
              queue.add(item);
            }
          }
        }
      }
    }
    return '';
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

  /// GET /Account/candidate/me/resume
  /// Returns: { statusCode, success, data: { sasUrl, expiresAt, succeeded }, errors }
  Future<Map<String, dynamic>> getResume() async {
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
