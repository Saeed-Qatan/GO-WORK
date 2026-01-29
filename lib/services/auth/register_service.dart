import 'package:gowork/model/auth/register_data_model.dart';
import 'package:gowork/utils/api_storage.dart';
import 'package:gowork/core/constants/api_constants.dart';

class RegisterService {
  final ApiClient _apiClient = ApiClient();

  Future<void> register(RegisterDataModel data) async {
    // 1. Submit basic info
    final response = await _apiClient.post(
      ApiConstants.register,
      data.toJson(),
    );

    // 2. Upload CV if exists (assuming a separate endpoint or handled in the same flow depending on backend design)
    // For this implementation, let's assume we upload CV separately or multipart if needed.
    // But since RegisterDataModel has file, we might need multipart form data for the whole thing or separate.
    // Based on ApiClient, if we have a file, typically we use multipart.

    // IF the backend expects everything in one go with multipart:
    if (data.cvFile != null) {
      await _apiClient.uploadFile(
        '${ApiConstants.register}/upload-cv', // Example endpoint, adjust as needed
        data.cvFile!,
        headers: {'userId': response['userId']}, // Example of linking
      );
    }

    // NOTE: The current plan assumed a simple register call.
    // Given the RegisterDataModel has a file mixed with data,
    // a real implementation often sends data first, gets ID, then uploads file, OR sends all as multipart.
    // I will implement a text-based register first as per common patterns, then CV upload if needed.
    // For now, I'll stick to the basic JSON post for data.
  }

  Future<void> uploadCV(String userId, var cvFile) async {
    // Implementation for CV upload if separate
    await _apiClient.uploadFile('${ApiConstants.register}/$userId/cv', cvFile);
  }
}
