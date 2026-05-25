import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gowork/model/auth/register_data_model.dart';
import 'package:gowork/repository/register_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('Test Registration API with random credentials', () async {
    // Required for plugins like shared_preferences
    TestWidgetsFlutterBinding.ensureInitialized();
    // Allow real network requests by bypassing the mock client
    HttpOverrides.global = null;

    // Mocking shared preferences because ApiClient/LocalStorage might use it
    SharedPreferences.setMockInitialValues({});

    final repository = RegisterRepository();

    // Generate unique credentials to avoid duplicate email/phone errors
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final email = 'test_$timestamp@test.com';
    // Generate a valid-looking 10-digit number starting with 059
    final phone = '059${(timestamp % 10000000).toString().padLeft(7, '0')}';

    final data = RegisterDataModel(
      firstName: 'Test',
      fatherName: 'Integration',
      familyName: 'User',
      email: email,
      phone: phone,
      password: 'Password123!',
      confirmPassword: 'Password123!',
      skills: ['Flutter', 'Testing'],
      categoryId: '101', // Default category for testing
    );

    debugPrint('=== START REGISTRATION API TEST ===');
    debugPrint('Email: $email');
    debugPrint('Phone: $phone');

    try {
      await repository.register(data);
      debugPrint('SUCCESS: User registered successfully.');
    } catch (e) {
      debugPrint('FAILURE: Registration failed with error: $e');
      // We fail the test if registration fails
      fail('Registration API failed: $e');
    }
    debugPrint('=== END REGISTRATION API TEST ===');
  });
}
