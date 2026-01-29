import 'package:gowork/services/profile/profile_service.dart';
import 'package:gowork/model/profile_model.dart';

class ProfileRepository {
  final ProfileService _service = ProfileService();

  Future<ProfileModel> getUserProfile() async {
    final data = await _service.getUserProfile();
    return ProfileModel.fromJson(data);
  }
}
