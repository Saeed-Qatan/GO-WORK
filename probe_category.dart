import 'package:dio/dio.dart';

void main() async {
  final dio = Dio(BaseOptions(
    baseUrl: 'https://api.masarak.app/api/',
    headers: {'Accept': 'application/json'},
    validateStatus: (status) => true, // Don't throw on 400
  ));

  final testIds = [
    ...List.generate(130, (i) => i + 21), // 21 to 150
    ...List.generate(10, (i) => i * 100), // 100, 200...
    1000, 1001, 10000, 99999
  ];

  for (int i in testIds) {
    final formData = FormData.fromMap({
      'firstName': 'Test',
      'midName': 'Test',
      'lastName': 'Test',
      'email': 'test_$i@example.com',
      'phoneNumber': '777111222$i',
      'Password': 'Password123!',
      'PasswordConfirmation': 'Password123!',
      'interstedInCategoryId': i.toString(),
      'listOfSkills': 'Dart',
    });

    try {
      final response = await dio.post(
        'Account/Candidate/Register',
        data: formData,
      );

      final data = response.data;
      if (data is Map) {
        if (data['success'] == true) {
          print('SUCCESS with ID $i');
          break;
        } else {
          final errors = data['errors'] ?? [];
          final errorStr = errors.toString();
          if (!errorStr.contains('Invalid category ID')) {
            print('ID $i IS VALID! Error was different: $errorStr');
            break;
          } else {
            print('ID $i is invalid.');
          }
        }
      }
    } catch (e) {
      print('Error testing ID $i: $e');
    }
  }
}
