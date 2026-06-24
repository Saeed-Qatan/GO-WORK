// ignore_for_file: avoid_print

import 'package:gowork/utils/api_storage.dart';
import 'package:gowork/core/constants/api_constants.dart';

void main() async {
  final apiClient = ApiClient();

  // Fake update to see what backend returns
  try {
    final fields = {'firstName': 'TestName', 'lastName': 'TestLast'};

    print('Testing PATCH...');
    final response = await apiClient.patchMultipart(
      ApiConstants.updateProfile,
      fields: fields,
    );
    print('PATCH Response: $response');
  } catch (e) {
    print('PATCH Failed: $e');
  }
}
