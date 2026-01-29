import 'package:flutter/material.dart';
import '../../model/profile_model.dart';

import '../../repository/profile_repository.dart';

class ProfileViewModel extends ChangeNotifier {
  final ProfileRepository _repository = ProfileRepository();
  ProfileModel? _profile;
  ProfileModel? get profile => _profile;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  ProfileViewModel() {
    fetchProfile();
  }

  Future<void> fetchProfile() async {
    _isLoading = true;
    notifyListeners();

    try {
      _profile = await _repository.getUserProfile();
    } catch (e) {
      debugPrint('Error fetching profile: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
