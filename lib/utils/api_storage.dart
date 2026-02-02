import 'dart:convert';
import 'package:gowork/core/constants/api_constants.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:gowork/utils/local_storage.dart';

class ApiClient {
  Future<Map<String, String>> _getHeaders(
    Map<String, String>? extraHeaders,
  ) async {
    final token = await LocalStorage().getString('token');
    final Map<String, String> headers = Map.from(ApiConstants.headers);

    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    if (extraHeaders != null) {
      headers.addAll(extraHeaders);
    }

    return headers;
  }

  Future<Map<String, dynamic>> get(
    String endpoint, {
    Map<String, String>? headers,
  }) async {
    final url = Uri.parse('${ApiConstants.baseUrl}$endpoint');
    final requestHeaders = await _getHeaders(headers);

    final response = await http.get(url, headers: requestHeaders);
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> post(
    String endpoint,
    Map<String, dynamic> body, {
    Map<String, String>? headers,
  }) async {
    final url = Uri.parse('${ApiConstants.baseUrl}$endpoint');
    final requestHeaders = await _getHeaders(headers);

    final response = await http.post(
      url,
      headers: requestHeaders,
      body: jsonEncode(body),
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> put(
    String endpoint,
    Map<String, dynamic> body, {
    Map<String, String>? headers,
  }) async {
    final url = Uri.parse('${ApiConstants.baseUrl}$endpoint');
    final requestHeaders = await _getHeaders(headers);

    final response = await http.put(
      url,
      headers: requestHeaders,
      body: jsonEncode(body),
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> delete(
    String endpoint, {
    Map<String, String>? headers,
  }) async {
    final url = Uri.parse('${ApiConstants.baseUrl}$endpoint');
    final requestHeaders = await _getHeaders(headers);

    final response = await http.delete(url, headers: requestHeaders);
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> uploadFile(
    String endpoint,
    File file, {
    Map<String, String>? headers,
  }) async {
    final url = Uri.parse('${ApiConstants.baseUrl}$endpoint');
    final request = http.MultipartRequest('POST', url);

    final requestHeaders = await _getHeaders(headers);
    request.headers.addAll(requestHeaders);

    request.files.add(await http.MultipartFile.fromPath('file', file.path));

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);

    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> postMultipart(
    String endpoint, {
    Map<String, String>? fields,
    List<MapEntry<String, String>>? repeatedFields,
    Map<String, File>? files,
    Map<String, String>? headers,
  }) async {
    final url = Uri.parse('${ApiConstants.baseUrl}$endpoint');
    final request = http.MultipartRequest('POST', url);

    final requestHeaders = await _getHeaders(headers);
    request.headers.addAll(requestHeaders);

    if (fields != null) {
      request.fields.addAll(fields);
    }

    if (repeatedFields != null) {
      for (var entry in repeatedFields) {
        request.files.add(
          http.MultipartFile.fromString(entry.key, entry.value),
        );
      }
    }

    if (files != null) {
      for (var entry in files.entries) {
        request.files.add(
          await http.MultipartFile.fromPath(entry.key, entry.value.path),
        );
      }
    }

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);

    return _handleResponse(response);
  }

  dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body);
    } else {
      // You might want to throw custom exceptions here based on status code
      throw Exception('Error ${response.statusCode}: ${response.body}');
    }
  }
}
