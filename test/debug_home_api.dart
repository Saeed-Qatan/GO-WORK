import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

/// Direct Dio test — bypasses all app code to see raw backend responses.
void main() {
  test('Debug Home API - raw responses', () async {
    TestWidgetsFlutterBinding.ensureInitialized();

    final dio = Dio(BaseOptions(
      baseUrl: 'https://api.masarak.app/api/',
      headers: {'Accept': 'application/json'},
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
    ));

    // 1. Login
    print('=== STEP 1: LOGIN ===');
    String? token;
    try {
      final loginResp = await dio.post(
        'Account/Candidate/Login',
        data: {'email': 'test_1777641740881@test.com', 'password': 'Password123!'},
        options: Options(contentType: 'application/json'),
      );
      print('Login status: ${loginResp.statusCode}');
      print('Login body type: ${loginResp.data.runtimeType}');
      print('Login body: ${loginResp.data}');

      if (loginResp.data is Map) {
        token = loginResp.data['token'] ??
            loginResp.data['data']?['token'] ??
            loginResp.data['accessToken'];
      }
      print('Extracted token: $token');
    } on DioException catch (e) {
      print('Login FAILED: ${e.response?.statusCode} => ${e.response?.data}');
    }

    if (token == null || token.isEmpty) {
      print('\n*** CANNOT CONTINUE WITHOUT TOKEN ***');
      return;
    }

    final authHeaders = Options(headers: {'Authorization': 'Bearer $token'});

    // 2. Account/Me
    print('\n=== STEP 2: Account/Me ===');
    try {
      final resp = await dio.get('Account/Me', options: authHeaders);
      print('Status: ${resp.statusCode}');
      print('Body type: ${resp.data.runtimeType}');
      print('Body: ${resp.data}');
    } on DioException catch (e) {
      print('FAILED: ${e.response?.statusCode} => ${e.response?.data}');
    }

    // 3. Jobs/recommendations
    print('\n=== STEP 3: Jobs/recommendations ===');
    try {
      final resp = await dio.get('Jobs/recommendations', options: authHeaders);
      print('Status: ${resp.statusCode}');
      print('Body type: ${resp.data.runtimeType}');
      print('Body: ${resp.data}');
    } on DioException catch (e) {
      print('FAILED: ${e.response?.statusCode} => ${e.response?.data}');
    }

    // 4. Account/applications
    print('\n=== STEP 4: Account/applications ===');
    try {
      final resp = await dio.get('Account/applications', options: authHeaders);
      print('Status: ${resp.statusCode}');
      print('Body type: ${resp.data.runtimeType}');
      print('Body: ${resp.data}');
    } on DioException catch (e) {
      print('FAILED: ${e.response?.statusCode} => ${e.response?.data}');
    }

    // 5. Account/interviews
    print('\n=== STEP 5: Account/interviews ===');
    try {
      final resp = await dio.get('Account/interviews', options: authHeaders);
      print('Status: ${resp.statusCode}');
      print('Body type: ${resp.data.runtimeType}');
      print('Body: ${resp.data}');
    } on DioException catch (e) {
      print('FAILED: ${e.response?.statusCode} => ${e.response?.data}');
    }

    print('\n=== DONE ===');
  });
}
