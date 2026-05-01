import 'package:flutter_test/flutter_test.dart';
import 'package:gowork/model/auth/register_data_model.dart';
import 'package:gowork/repository/register_repository.dart';

void main() {
  test('Test Registration Backend Connection', () async {
    final repo = RegisterRepository();
    final data = RegisterDataModel(
      firstName: 'TestFirst',
      fatherName: 'TestFather',
      familyName: 'TestFamily',
      email: 'test_${DateTime.now().millisecondsSinceEpoch}@test.com',
      phone: '77${DateTime.now().millisecondsSinceEpoch.toString().substring(5, 12)}',
      password: 'Password123!',
      confirmPassword: 'Password123!',
      categoryId: '101',
      skills: ['Flutter', 'Dart'],
    );

    try {
      print('Attempting to register account: ${data.email}');
      await repo.register(data);
      print('Registration successful! Connection to backend is correct.');
    } catch (e) {
      print('Registration failed: $e');
      fail('Connection failed: $e');
    }
  });
}
