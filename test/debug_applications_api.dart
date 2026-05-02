import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    
    if (token == null || token.isEmpty) {
      print('No auth token found in SharedPreferences.');
      return;
    }
    
    final dio = Dio();
    dio.options.headers['Authorization'] = 'Bearer $token';
    dio.options.headers['Accept'] = 'application/json';
    
    print('Fetching Account/applications...');
    final response = await dio.get('https://api.masarak.app/api/Account/applications');
    
    print('Status Code: ${response.statusCode}');
    print('Data type: ${response.data.runtimeType}');
    
    if (response.data is Map) {
      print('Keys: ${(response.data as Map).keys.toList()}');
      print('Response:');
      print(const JsonEncoder.withIndent('  ').convert(response.data));
    } else {
      print('Response: ${response.data}');
    }
    
    print('==============================');
    print('Fetching Applications/statuses...');
    final statusResponse = await dio.get('https://api.masarak.app/api/Applications/statuses');
    if (statusResponse.data is Map) {
      print('Status Keys: ${(statusResponse.data as Map).keys.toList()}');
      print('Status Response:');
      print(const JsonEncoder.withIndent('  ').convert(statusResponse.data));
    } else {
      print('Status Response: ${statusResponse.data}');
    }

  } catch (e) {
    if (e is DioException) {
      print('DioError: ${e.response?.statusCode} - ${e.response?.data}');
    } else {
      print('Error: $e');
    }
  }
}
