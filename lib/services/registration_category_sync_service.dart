import 'package:flutter/foundation.dart';

import 'package:gowork/model/profile_model.dart';
import 'package:gowork/repository/profile_repository.dart';
import 'package:gowork/utils/local_storage.dart';

class RegistrationCategorySyncService {
  final LocalStorage _storage;
  final ProfileRepository _profileRepository;

  RegistrationCategorySyncService({
    LocalStorage? storage,
    ProfileRepository? profileRepository,
  }) : _storage = storage ?? LocalStorage(),
       _profileRepository = profileRepository ?? ProfileRepository();

  Future<void> savePendingCategory({
    required String email,
    required String categoryId,
  }) {
    return _storage.savePendingRegistrationCategoryId(
      email: email,
      categoryId: categoryId,
    );
  }

  Future<String?> consumePendingCategory(String email) {
    return _storage.consumePendingRegistrationCategoryId(email);
  }

  Future<void> syncProfileCategory({
    required ProfileModel profile,
    required String? categoryId,
  }) async {
    final normalizedCategoryId = categoryId?.trim();
    if (normalizedCategoryId == null || normalizedCategoryId.isEmpty) return;

    final fields = <String, String>{
      'InterstedInCategoryId': normalizedCategoryId,
    };
    if (profile.firstName.trim().isNotEmpty) {
      fields['FirstName'] = profile.firstName.trim();
    }
    if (profile.middleName.trim().isNotEmpty) {
      fields['MiddleName'] = profile.middleName.trim();
    }
    if (profile.lastName.trim().isNotEmpty) {
      fields['LastName'] = profile.lastName.trim();
    }
    if (profile.jobTitle.trim().isNotEmpty) {
      fields['JobTitle'] = profile.jobTitle.trim();
    }
    if (profile.phone.trim().isNotEmpty) {
      fields['phoneNo'] = profile.phone.trim();
    }

    final repeatedFields = profile.skills
        .map((skill) => skill.trim())
        .where((skill) => skill.isNotEmpty)
        .map((skill) => MapEntry('Skills', skill))
        .toList();

    try {
      await _profileRepository.updateProfile(
        fields: fields,
        repeatedFields: repeatedFields.isEmpty ? null : repeatedFields,
      );
      await _storage.saveScopedString('categoryId', normalizedCategoryId);
    } catch (e) {
      debugPrint('=== REGISTER CATEGORY PROFILE SYNC ERROR: $e ===');
    }
  }
}
