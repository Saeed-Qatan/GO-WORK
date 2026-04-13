import 'package:dio/dio.dart';
import 'dart:io';

void main() async {
  var dio = Dio(BaseOptions(
    baseUrl: 'https://api.masarak.app/api/',
    validateStatus: (status) => true,
  ));

  print('1. Registering dummy user...');
  var formData = FormData.fromMap({
    'firstName': 'JobTest',
    'midName': 'User',
    'lastName': 'Account',
    'email': 'jobtest992@test.com',
    'phoneNumber': '0500000000',
    'Password': 'Password123!',
    'PasswordConfirmation': 'Password123!',
    'interstedInCategoryId': '101', 
    'listOfSkills': 'Flutter',
  });

  var regResponse = await dio.post('Account/Candidate/Register', data: formData);
  print('Register status: ${regResponse.statusCode}');
  
  print('2. Logging in...');
  var loginResponse = await dio.post('Account/Candidate/Login', data: {
    'Email': 'jobtest992@test.com',
    'Password': 'Password123!',
  });
  
  print('Login status: ${loginResponse.statusCode}');
  var token = loginResponse.data['data']?['token'];
  
  if (token == null) {
      print('Cannot get token, trying generic error response: ${loginResponse.data}');
      return;
  }
  
  print('3. Fetching jobs/recommendations...');
  var jobsResponse = await dio.get('Jobs/recommendations', options: Options(
    headers: {'Authorization': 'Bearer $token'}
  ));
  
  print('Jobs status: ${jobsResponse.statusCode}');
  print('Jobs data: ${jobsResponse.data}');
}
