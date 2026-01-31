import 'package:gowork/services/profile_service.dart';
import 'package:gowork/model/profile_model.dart';

class ProfileRepository {
  final ProfileService _service = ProfileService();

  Future<ProfileModel> getUserProfile() async {
    final response = await _service.getUserProfile();
    // Assuming the response might be nested or direct
    final data = response['user'] ?? response['data'] ?? response;
    return ProfileModel.fromJson(data);
  }

  Future<void> updateProfile(Map<String, dynamic> data) async {
    await _service.updateProfile(data);
  }
}
