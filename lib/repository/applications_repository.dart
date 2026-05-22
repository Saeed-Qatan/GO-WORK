import 'package:flutter/foundation.dart';
import 'package:gowork/model/application_model.dart';
import 'package:gowork/core/constants/api_constants.dart';
import 'package:gowork/utils/api_storage.dart';

class ApplicationsRepository {
  final ApiClient _apiClient;

  ApplicationsRepository({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient();

  Future<List<ApplicationModel>> getApplications() async {
    try {
      debugPrint('=== APPLICATIONS: Fetching ${ApiConstants.applications} ===');
      final response = await _apiClient.get(ApiConstants.applications);
      debugPrint(
        '=== APPLICATIONS: response keys: ${response.keys.toList()} ===',
      );

      if (response.containsKey('data')) {
        debugPrint(
          '=== APPLICATIONS: data type: ${response['data'].runtimeType} ===',
        );
        if (response['data'] is Map) {
          debugPrint(
            '=== APPLICATIONS: data keys: ${(response['data'] as Map).keys.toList()} ===',
          );
        }
      }

      List<dynamic> rawList = [];

      if (response['data'] != null && response['data'] is List) {
        rawList = response['data'] as List;
      } else if (response['data'] != null && response['data'] is Map) {
        final dataMap = response['data'] as Map<String, dynamic>;
        if (dataMap.containsKey('items') && dataMap['items'] is List) {
          rawList = dataMap['items'] as List;
        } else if (dataMap.containsKey('applications') &&
            dataMap['applications'] is List) {
          rawList = dataMap['applications'] as List;
        }
      } else if (response['applications'] != null &&
          response['applications'] is List) {
        rawList = response['applications'] as List;
      } else if (response['items'] != null && response['items'] is List) {
        rawList = response['items'] as List;
      }

      debugPrint('=== APPLICATIONS: Found ${rawList.length} raw items ===');

      return rawList
          .map((json) {
            try {
              return ApplicationModel.fromJson(json as Map<String, dynamic>);
            } catch (e) {
              debugPrint('=== APPLICATIONS: Error parsing item: $e ===');
              return ApplicationModel(
                id: '',
                jobId: '',
                role: 'تعذر قراءة الطلب',
                company: 'غير معروف',
                companyLogo: '',
                date: '',
                statusName: ApplicationStatus.sent.arabicLabel,
                rawStatusName: '',
                status: ApplicationStatus.sent,
              );
            }
          })
          .where((app) => app.id.isNotEmpty)
          .toList();
    } catch (e) {
      debugPrint('=== APPLICATIONS ERROR: $e ===');
      rethrow;
    }
  }

  Future<List<dynamic>> getApplicationStatuses() async {
    try {
      final response = await _apiClient.get(ApiConstants.applicationStatuses);
      if (response['data'] != null && response['data'] is List) {
        return response['data'] as List<dynamic>;
      }
      return [];
    } catch (e) {
      // If endpoint doesn't exist or fails, return empty list to fallback
      return [];
    }
  }

  Future<void> withdrawApplication(String applicationId) async {
    final response = await _apiClient.post(
      '${ApiConstants.withdrawApplication}/$applicationId',
      {},
    );

    // Explicitly check the success flag from the backend response
    if (response['success'] != true) {
      // Extract the backend message — but only use it if it's Arabic text.
      // Otherwise fall back to a safe generic Arabic message.
      final errors = response['errors'];
      String? rawMsg;

      if (errors is List && errors.isNotEmpty) {
        rawMsg = errors.join('\n');
      } else if (errors is String && errors.trim().isNotEmpty) {
        rawMsg = errors;
      } else if (response['message'] != null) {
        rawMsg = response['message'].toString();
      } else if (response['data']?['message'] != null) {
        rawMsg = response['data']['message'].toString();
      }

      // Only surface the message if it's already Arabic, otherwise use a safe default.
      final bool isArabic =
          rawMsg != null && RegExp(r'[\u0600-\u06FF]').hasMatch(rawMsg);
      final String message = isArabic
          ? rawMsg
          : 'لا يمكن سحب هذا الطلب في وضعه الحالي';

      throw Exception(message);
    }
  }
}
