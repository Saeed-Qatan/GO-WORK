// ignore_for_file: avoid_print

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Debug Search API', () async {
    TestWidgetsFlutterBinding.ensureInitialized();

    final dio = Dio(
      BaseOptions(
        baseUrl: 'https://api.masarak.app/api/',
        headers: {'Accept': 'application/json'},
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
      ),
    );

    // Login
    print('=== LOGIN ===');
    String? token;
    try {
      final loginResp = await dio.post(
        'Account/Candidate/Login',
        data: {
          'email': 'test_1777641740881@test.com',
          'password': 'Password123!',
        },
        options: Options(contentType: 'application/json'),
      );
      if (loginResp.data is Map) {
        token = loginResp.data['token'] ??
            loginResp.data['data']?['token'] ??
            loginResp.data['accessToken'];
      }
      print('Token: $token');
    } on DioException catch (e) {
      print('Login FAILED: ${e.response?.statusCode} => ${e.response?.data}');
      return;
    }

    if (token == null) return;
    final authHeaders = Options(headers: {'Authorization': 'Bearer $token'});

    // Search without parameters
    print('\n=== SEARCH NO PARAMS ===');
    try {
      final resp = await dio.get('Jobs/search', options: authHeaders);
      print('No params status: ${resp.statusCode}');
      if (resp.data is Map) {
        final data = resp.data['data'];
        final list = data is Map ? data['jobs'] : data;
        print('Count: ${list?.length}');
        if (list is List && list.isNotEmpty) {
          print('First job: ${list.first}');
        }
      }
    } on DioException catch (e) {
      print('Search failed: ${e.response?.statusCode} => ${e.response?.data}');
    }

    // Search with query parameter: query
    print('\n=== SEARCH WITH query=developer ===');
    try {
      final resp = await dio.get('Jobs/search', queryParameters: {'query': 'developer'}, options: authHeaders);
      print('Query parameter "query" status: ${resp.statusCode}');
      if (resp.data is Map) {
        final data = resp.data['data'];
        final list = data is Map ? data['jobs'] : data;
        print('Count: ${list?.length}');
        if (list is List && list.isNotEmpty) {
          print('First job title: ${list.first['title']}');
        }
      }
    } on DioException catch (e) {
      print('Query search failed: ${e.response?.statusCode}');
    }

    // Search with query parameter: search
    print('\n=== SEARCH WITH search=developer ===');
    try {
      final resp = await dio.get('Jobs/search', queryParameters: {'search': 'developer'}, options: authHeaders);
      print('Query parameter "search" status: ${resp.statusCode}');
      if (resp.data is Map) {
        final data = resp.data['data'];
        final list = data is Map ? data['jobs'] : data;
        print('Count: ${list?.length}');
        if (list is List && list.isNotEmpty) {
          print('First job title: ${list.first['title']}');
        }
      }
    } on DioException catch (e) {
      print('Search parameter search failed: ${e.response?.statusCode}');
    }
  });
}
