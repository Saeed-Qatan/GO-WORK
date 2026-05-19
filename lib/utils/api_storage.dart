import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:gowork/core/constants/api_constants.dart';
import 'dart:io';
import 'package:gowork/utils/local_storage.dart';

class ApiClient {
  late final Dio _dio;

  ApiClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        headers: ApiConstants.headers,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Skip auth for public endpoints (e.g. registration)
          if (options.extra['skipAuth'] == true) {
            debugPrint('--- SKIP AUTH (public endpoint) ---');
            return handler.next(options);
          }
          final token = await LocalStorage().getString('token');
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
            debugPrint('--- JWT SENT ---');
          } else {
            debugPrint('--- NO JWT TOKEN FOUND IN STORAGE ---');
          }
          return handler.next(options);
        },
        onError: (DioException e, handler) async {
          if (e.response?.statusCode == 401) {
            // Token expired or invalid, clear local storage
            await LocalStorage().remove('token');
            await LocalStorage().remove('userId');
            // We return a specialized exception so UI can route to login if needed
            return handler.next(
              e.copyWith(
                error: 'انتهت صلاحية الجلسة، يرجى تسجيل الدخول مجدداً.',
              ),
            );
          }
          return handler.next(e);
        },
      ),
    );
  }

  Future<Map<String, dynamic>> get(
    String endpoint, {
    Map<String, String>? headers,
    bool skipAuth = false,
  }) async {
    try {
      final response = await _dio.get(
        endpoint,
        options: Options(
          headers: headers,
          contentType: 'application/json',
          extra: {'skipAuth': skipAuth},
        ),
      );
      return _handleResponse(response);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Map<String, dynamic>> post(
    String endpoint,
    Map<String, dynamic> body, {
    Map<String, String>? headers,
    bool skipAuth = false,
  }) async {
    try {
      final response = await _dio.post(
        endpoint,
        data: body,
        options: Options(
          headers: headers,
          contentType: 'application/json',
          extra: {'skipAuth': skipAuth},
        ),
      );
      return _handleResponse(response);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Map<String, dynamic>> put(
    String endpoint,
    Map<String, dynamic> body, {
    Map<String, String>? headers,
  }) async {
    try {
      final response = await _dio.put(
        endpoint,
        data: body,
        options: Options(headers: headers, contentType: 'application/json'),
      );
      return _handleResponse(response);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Map<String, dynamic>> patch(
    String endpoint,
    Map<String, dynamic> body, {
    Map<String, String>? headers,
  }) async {
    try {
      final response = await _dio.patch(
        endpoint,
        data: body,
        options: Options(headers: headers, contentType: 'application/json'),
      );
      return _handleResponse(response);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Map<String, dynamic>> delete(
    String endpoint, {
    Map<String, String>? headers,
  }) async {
    try {
      final response = await _dio.delete(
        endpoint,
        options: Options(headers: headers, contentType: 'application/json'),
      );
      return _handleResponse(response);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Map<String, dynamic>> uploadFile(
    String endpoint,
    File file, {
    Map<String, String>? headers,
  }) async {
    try {
      String fileName = file.path.split(RegExp(r'[/\\]')).last;
      FormData formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(file.path, filename: fileName),
      });

      final response = await _dio.post(
        endpoint,
        data: formData,
        options: Options(headers: headers),
      );
      return _handleResponse(response);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Map<String, dynamic>> postMultipart(
    String endpoint, {
    Map<String, String>? fields,
    List<MapEntry<String, String>>? repeatedFields,
    Map<String, File>? files,
    Map<String, String>? headers,
    bool skipAuth = false,
  }) async {
    try {
      final formData = FormData();

      if (fields != null) {
        fields.forEach((key, value) {
          formData.fields.add(MapEntry(key, value));
        });
      }

      if (repeatedFields != null) {
        formData.fields.addAll(repeatedFields);
      }

      if (files != null) {
        for (var entry in files.entries) {
          formData.files.add(
            MapEntry(
              entry.key,
              await MultipartFile.fromFile(
                entry.value.path,
                filename: entry.value.path.split(RegExp(r'[/\\]')).last,
              ),
            ),
          );
        }
      }

      debugPrint('=== MULTIPART REQUEST ===');
      debugPrint('Endpoint: $endpoint');
      debugPrint('Fields: ${formData.fields}');
      debugPrint(
        'Files: ${formData.files.map((f) => '${f.key}: ${f.value.filename}').toList()}',
      );
      debugPrint('skipAuth: $skipAuth');
      debugPrint('=========================');

      final response = await _dio.post(
        endpoint,
        data: formData,
        options: Options(headers: headers, extra: {'skipAuth': skipAuth}),
      );
      return _handleResponse(response);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Map<String, dynamic>> putMultipart(
    String endpoint, {
    Map<String, String>? fields,
    List<MapEntry<String, String>>? repeatedFields,
    Map<String, File>? files,
    Map<String, String>? headers,
  }) async {
    try {
      final formData = FormData();

      if (fields != null) {
        fields.forEach((key, value) {
          formData.fields.add(MapEntry(key, value));
        });
      }

      if (repeatedFields != null) {
        formData.fields.addAll(repeatedFields);
      }

      if (files != null) {
        for (var entry in files.entries) {
          formData.files.add(
            MapEntry(
              entry.key,
              await MultipartFile.fromFile(
                entry.value.path,
                filename: entry.value.path.split(RegExp(r'[/\\]')).last,
              ),
            ),
          );
        }
      }

      final response = await _dio.put(
        endpoint,
        data: formData,
        options: Options(headers: headers),
      );
      return _handleResponse(response);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Map<String, dynamic>> patchMultipart(
    String endpoint, {
    Map<String, String>? fields,
    List<MapEntry<String, String>>? repeatedFields,
    Map<String, File>? files,
    Map<String, String>? headers,
  }) async {
    try {
      final formData = FormData();

      if (fields != null) {
        fields.forEach((key, value) {
          formData.fields.add(MapEntry(key, value));
        });
      }

      if (repeatedFields != null) {
        formData.fields.addAll(repeatedFields);
      }

      if (files != null) {
        for (var entry in files.entries) {
          formData.files.add(
            MapEntry(
              entry.key,
              await MultipartFile.fromFile(
                entry.value.path,
                filename: entry.value.path.split(RegExp(r'[/\\]')).last,
              ),
            ),
          );
        }
      }

      final response = await _dio.patch(
        endpoint,
        data: formData,
        options: Options(headers: headers),
      );
      return _handleResponse(response);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Map<String, dynamic> _handleResponse(Response response) {
    if (response.statusCode != null &&
        response.statusCode! >= 200 &&
        response.statusCode! < 300) {
      if (response.data is Map<String, dynamic>) {
        return response.data;
      }
      if (response.data is List) {
        return {'data': response.data};
      }
      // If data is somehow not a Map (e.g. empty), return empty map.
      return <String, dynamic>{};
    } else {
      throw Exception('Error ${response.statusCode}: ${response.data}');
    }
  }

  Exception _handleDioError(DioException e) {
    if (e.response != null) {
      return Exception('Error ${e.response?.statusCode}: ${e.response?.data}');
    } else {
      return Exception('Network Error: ${e.message}');
    }
  }
}
