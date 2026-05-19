import 'package:flutter_test/flutter_test.dart';
import 'package:gowork/core/constants/api_constants.dart';
import 'package:gowork/utils/api_storage.dart';
import 'package:gowork/utils/local_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('Test Home API structure', () async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    final client = ApiClient();
    
    // Login to get token
    print('Logging in...');
    try {
      final loginResp = await client.post(
        ApiConstants.login,
        {
          'email': 'test_1777641740881@test.com',
          'password': 'Password123!'
        },
      );
      
      final token = loginResp['data']?['token'];
      if (token == null) {
        print('Could not get token! Login resp: $loginResp');
        return;
      }
      print('Got token: $token');
      
      // Store token
      await LocalStorage().saveString('token', token);
      
      // Fetch Account/Me
      print('\nFetching Account/Me...');
      try {
        final profileResp = await client.get(ApiConstants.getProfile);
        print('Profile Response: $profileResp');
      } catch (e) {
        print('Profile error: $e');
      }
      
      // Fetch Jobs/recommendations
      print('\nFetching Jobs/recommendations...');
      try {
        final jobsResp = await client.get(ApiConstants.recommendedJobs);
        print('Jobs Response: $jobsResp');
      } catch (e) {
        print('Jobs error: $e');
      }
      
    } catch (e) {
      print('Login error: $e');
    }
  });
}
