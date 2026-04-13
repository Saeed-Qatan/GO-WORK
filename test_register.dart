import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import 'dart:io';

void main() async {
  var dio = Dio();
  
  // Try sending a request with 101 category ID which worked before
  try {
    var dummyFile = File('dummy.pdf');
    if (!dummyFile.existsSync()) {
      dummyFile.writeAsStringSync('dummy pdf content');
    }

    var dummyFile2 = File('dummy.jpg');
    if (!dummyFile2.existsSync()) {
      dummyFile2.writeAsStringSync('dummy photo content');
    }

    var formData = FormData();
    formData.fields.addAll([
      MapEntry('firstName', 'TestMultiSkill'),
      MapEntry('midName', 'User'),
      MapEntry('lastName', 'Account'),
      MapEntry('email', 'testmultiskill@test.com'),
      MapEntry('phoneNumber', '0500000000'),
      MapEntry('Password', 'Password123!'),
      MapEntry('PasswordConfirmation', 'Password123!'),
      MapEntry('interstedInCategoryId', '101'),
      MapEntry('listOfSkills', 'Flutter'),
      MapEntry('listOfSkills', 'Dart'),
    ]);
    
    formData.files.addAll([
      MapEntry('Resume', await MultipartFile.fromFile('dummy.pdf', filename: 'dummy.pdf')),
      MapEntry('ProfilePhoto', await MultipartFile.fromFile('dummy.jpg', filename: 'dummy.jpg')),
    ]);

    print('Sending request with multiple skills...');
    var response = await dio.post(
      'https://api.masarak.app/api/Account/Candidate/Register',
      data: formData,
    );
    print('Success: ${response.statusCode}');
    print(response.data);
  } on DioException catch (e) {
    if (e.response != null) {
      print('Status: ${e.response?.statusCode}');
      print('Data: ${e.response?.data}');
    } else {
      print('Error: ${e.message}');
    }
  }
}
